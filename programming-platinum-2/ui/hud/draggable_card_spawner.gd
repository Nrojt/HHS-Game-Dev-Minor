extends VBoxContainer

@export_group("Draggables")
@export var DRAGGABLE_SCENES: Array[PackedScene] = [
	preload("uid://7p7ercjif3ja"),
	preload("uid://buutu78g1kur"),
	preload("uid://bkmpcsxb0jjy0")
]

@export_group("Cards")
@export var draggable_card_scene: PackedScene = preload("uid://bhpx3a7ome13w")
@export var max_cards_at_once := 4
@export var base_spawn_interval := 4.0
@export var min_spawn_interval := 0.5
@export var post_reshuffle_spawn_delay: float = 0.25

@onready var spawn_timer: Timer = $SpawnTimer

var _last_draggable_scene: PackedScene = null
var _is_reshuffling_cards: bool = false
var _pending_reshuffle: bool = false

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	self.child_exiting_tree.connect(_on_child_exiting_tree)
	_update_spawn_timer()
	spawn_timer.start()
	_spawn_card()

func _on_spawn_timer_timeout() -> void:
	if _is_reshuffling_cards:
		spawn_timer.start()
		return # Don't spawn if cards are moving

	if _get_card_count() < max_cards_at_once:
		_spawn_card()
	_update_spawn_timer()

func _update_spawn_timer():
	var movement_speed = GameManager.movement_speed
	var interval: float = base_spawn_interval / (1.0 + log(1.0 + movement_speed))
	interval = max(min_spawn_interval, interval)
	spawn_timer.wait_time = interval

func _get_card_count() -> int:
	var count: int = 0
	for child in get_children():
		if child is DraggableCard:
			count += 1
	return count

func _spawn_card() -> void:
	if _is_reshuffling_cards:
		return

	if DRAGGABLE_SCENES.is_empty():
		push_error("Error: No draggable scenes defined for spawner.")
		return
	if draggable_card_scene == null:
		push_error("Error: Draggable card scene not set in spawner.")
		return

	var possible_scenes: Array[PackedScene] = []
	for scene in DRAGGABLE_SCENES:
		if scene != _last_draggable_scene or DRAGGABLE_SCENES.size() == 1:
			possible_scenes.append(scene)
	if possible_scenes.is_empty():
		possible_scenes = DRAGGABLE_SCENES.duplicate()
	if possible_scenes.is_empty():
		push_error("Error: No possible scenes to pick from for spawning.")
		return

	var random_draggable_scene: PackedScene = possible_scenes.pick_random()
	_last_draggable_scene = random_draggable_scene

	var new_card_instance: Node = draggable_card_scene.instantiate()
	if new_card_instance is DraggableCard:
		var new_card: DraggableCard = new_card_instance
		add_child(new_card)
		move_child(new_card, 0)
		new_card.set_draggable_scene(random_draggable_scene)
		new_card.play_entry_animation()
	else:
		push_error("Error: Failed to instantiate/wrong type for card scene.")
		if new_card_instance:
			new_card_instance.queue_free()

func _on_child_exiting_tree(node: Node):
	if node is DraggableCard:
		if _is_reshuffling_cards:
			_pending_reshuffle = true
		else:
			_is_reshuffling_cards = true
			call_deferred("_initiate_card_reshuffle_animation")


func _initiate_card_reshuffle_animation() -> void:
	while true:
		_pending_reshuffle = false

		var card_data_before_layout: Array[Dictionary] = []
		for child in get_children():
			if child is DraggableCard:
				card_data_before_layout.append({
					"card": child,
					"old_global_pos": child.global_position
				})

		if card_data_before_layout.is_empty():
			_is_reshuffling_cards = false
			return

		await get_tree().process_frame

		var animation_tweens: Array[Tween] = []
		var stagger_delay := 0.05
		var current_delay := 0.0

		for item_data in card_data_before_layout:
			var card: DraggableCard = item_data.card
			var old_pos: Vector2 = item_data.old_global_pos
			if not is_instance_valid(card):
				continue

			var new_target: Vector2 = card.position
			card.global_position = old_pos

			if current_delay > 0.0:
				await get_tree().create_timer(current_delay).timeout
			var tween: Tween = card.animate_to_position(new_target)
			animation_tweens.append(tween)
			current_delay += stagger_delay

		# Wait for all tweens to finish
		for tween in animation_tweens:
			if is_instance_valid(tween):
				await tween.finished

		# Small extra delay before allowing spawns
		if post_reshuffle_spawn_delay > 0.0:
			await get_tree().create_timer(post_reshuffle_spawn_delay).timeout

		# If another reshuffle was requested during this one, loop again
		if not _pending_reshuffle:
			break

	_is_reshuffling_cards = false
	# If timer is ready and we can spawn, do it now
	if _get_card_count() < max_cards_at_once and spawn_timer.time_left == 0.0:
		_on_spawn_timer_timeout()
