class_name DraggableCard
extends Control

@onready var title_label: Label = %TitleLabel
@onready var card_icon: TextureRect = %CardIcon
@onready var blur_rect: ColorRect = %BlurRect

var draggable_preview: DraggableBase = null

var is_dragging_card: bool = false

var show_blur := false:
	set(value):
		show_blur = value
		if blur_rect:
			blur_rect.visible = value

var drag_start_position: Vector2 = Vector2.ZERO

var _original_z_index: int = 0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_original_z_index = z_index
	# Initialize blur_rect's visibility based on the default value of show_blur.
	if blur_rect:
		blur_rect.visible = show_blur

# Function called by the spawner to assign the draggable scene this card represents
func set_draggable_scene(scene: PackedScene):
	if scene:
		var preview_instance: Node = scene.instantiate()
		if preview_instance is DraggableBase:
			draggable_preview = preview_instance
			if draggable_preview.name:
				title_label.text = draggable_preview.name
			else:
				title_label.text = "Unnamed Draggable"
			if draggable_preview.card_icon:
				card_icon.texture = draggable_preview.card_icon
			else:
				card_icon.texture = PlaceholderTexture2D.new()
		else:
			title_label.text = "Error Loading"
			push_error(
				"Error: Failed to instantiate or wrong type for preview scene: ",
				scene.resource_path
			)
			if preview_instance:
				preview_instance.queue_free()
			draggable_preview = null
	else:
		title_label.text = "No Scene"
		push_error("Error: set_draggable_scene called with null PackedScene.")
		draggable_preview = null

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start of a potential drag
				is_dragging_card = true
				show_blur = true
				drag_start_position = get_global_mouse_position()
			elif not event.pressed and is_dragging_card:
				# End of a drag or just a click
				is_dragging_card = false
				show_blur = false

	if event is InputEventMouseMotion:
		if is_dragging_card:
			# Check if the mouse has moved past a threshold distance to confirm it's a drag
			if (
				drag_start_position.distance_to(get_global_mouse_position())
				> 5
			):
				# Emit a signal with the associated preview
				if draggable_preview:
					GameManager.start_dragging_draggable.emit(
						self, draggable_preview
					)
				is_dragging_card = false

func _restore_z_index():
	z_index = _original_z_index

func _on_exit_animation_finished():
	queue_free()

## Animation that plays when the card is added to the scene. Fade in and scale up.
func play_entry_animation():
	modulate.a = 0.0
	scale = Vector2(0.7, 0.7)
	var initial_y_position: float = position.y
	position.y -= 35.0

	# Raise z_index
	z_index = 1000

	var tween := create_tween()
	tween.set_parallel(true)
	# Fade in
	tween.tween_property(self, "modulate:a", 1.0, 0.3)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Scale up with a little overshoot, then settle
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.35)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	# Move down to the final position
	tween.tween_property(self, "position:y", initial_y_position, 0.3)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Restore z_index after the pop is done
	tween.chain().tween_callback(_restore_z_index)

## Animation that plays when the card is removed from the scene. Fade out and scale down.
func play_exit_animation():
	mouse_filter = MOUSE_FILTER_IGNORE
	z_index = 1000

	var tween := create_tween()
	tween.set_parallel(true)
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.3)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	# Scale down with a little overshoot, then settle
	tween.tween_property(self, "scale", Vector2(0.75, 0.75), 0.3)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	# Move up to the final position
	tween.tween_property(self, "position:y", position.y + 25.0, 0.3)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_on_exit_animation_finished)

## Animates the card to the target local position and returns the Tween. To be used in the spawner.
func animate_to_position(target_local_position: Vector2) -> Tween:
	var tween := create_tween()
	if position.is_equal_approx(target_local_position):
		tween.tween_interval(0.0)
	else:
		tween.tween_property(self, "position", target_local_position, 0.35)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween
