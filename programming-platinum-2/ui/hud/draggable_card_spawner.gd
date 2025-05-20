extends VBoxContainer


@export_group("Draggables")
## Array of DraggableBase instances
@export var DRAGGABLE_SCENES: Array[PackedScene] = [
	preload("uid://7p7ercjif3ja"),
	preload("uid://buutu78g1kur"),
	preload("uid://bkmpcsxb0jjy0")
]

@export_group("Cards")
## Needs to be a DraggableCard instance
@export var draggable_card_scene : PackedScene = preload("uid://bhpx3a7ome13w")
@export var max_cards_at_once := 4

## seconds at default speed
@export var base_spawn_interval := 4.0
## never spawn faster than this
@export var min_spawn_interval := 0.5  

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_update_spawn_timer()
	spawn_timer.start()
	# spawn one initial card
	_spawn_card()

func _on_spawn_timer_timeout():
	if _get_card_count() < max_cards_at_once:
		_spawn_card()
	_update_spawn_timer()

func _update_spawn_timer():
	var movement_speed = GameManager.movement_speed
	# Logarithmic scaling, so the card drop speed lags behind movement speed
	var interval = base_spawn_interval / (1.0 + log(1.0 + movement_speed))
	interval = max(min_spawn_interval, interval)
	spawn_timer.wait_time = interval
	
func _get_card_count() -> int:
	var count = 0
	for child in get_children():
		if child is DraggableCard:
			count += 1
	return count

func _spawn_card():
	if DRAGGABLE_SCENES.is_empty():
		push_error("Error: No draggable scenes defined in DRAGGABLE_SCENES array for spawner.")
		return

	if draggable_card_scene == null:
		push_error("Error: Draggable card scene is not set in the spawner.")
		return

	var draggable_scene_index = randi_range(0, DRAGGABLE_SCENES.size() - 1)
	var random_draggable_scene : PackedScene = DRAGGABLE_SCENES[draggable_scene_index]
	var new_card = draggable_card_scene.instantiate()

	if new_card && new_card is DraggableCard:
		add_child(new_card)
		move_child(new_card, 0)
		new_card.set_draggable_scene(random_draggable_scene)
		print("Spawned a new card representing: ", random_draggable_scene.resource_path)
	else:
		push_error("Error: Failed to instantiate draggable card scene: ", draggable_card_scene.resource_path)
