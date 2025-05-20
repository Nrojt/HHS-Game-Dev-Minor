class_name DraggableCard
extends Control

@onready var title_label: Label = %TitleLabel

var draggable_preview : DraggableBase = null

var is_dragging_card: bool = false
var drag_start_position: Vector2 = Vector2.ZERO

var _original_z_index: int = 0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_original_z_index = z_index

# Function called by the spawner to assign the draggable scene this card represents
func set_draggable_scene(scene: PackedScene):
	if scene:
		var preview_instance: Node = scene.instantiate()
		if preview_instance:
			title_label.text = preview_instance.name
			draggable_preview = preview_instance # Store the instance for use during drag
		else:
			title_label.text = "Error Loading"
			push_error(
				"Error: Failed to instantiate preview scene: ",
				scene.resource_path
			)
	else:
		title_label.text = "No Scene"
		push_error("Error: set_draggable_scene called with null PackedScene.")

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start of a potential drag
				is_dragging_card = true
				drag_start_position = get_global_mouse_position()
			elif !event.pressed and is_dragging_card:
				# End of a drag or just a click
				is_dragging_card = false

	if event is InputEventMouseMotion:
		if is_dragging_card:
			# Check if the mouse has moved past a threshold distance to confirm it's a drag
			if drag_start_position.distance_to(get_global_mouse_position()) > 5:
				# Emit a signal with the associated preview
				if draggable_preview:
					GameManager.start_dragging_draggable.emit(self, draggable_preview)
				is_dragging_card = false

func play_entry_animation():
	# Start invisible, small, and slightly above the final position
	modulate.a = 0.0
	scale = Vector2(0.85, 0.85)
	position.y -= 30

	# Raise z_index
	z_index = 1000

	var tween := create_tween()
	# Fade in
	tween.tween_property(self, "modulate:a", 1.0, 0.22)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	# Scale up with a little overshoot, then settle
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.16)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.10)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	# Move down to the final position
	tween.tween_property(self, "position:y", position.y + 30, 0.18)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	# Restore z_index after the pop is done
	tween.tween_callback(Callable(self, "_restore_z_index"))

func _restore_z_index():
	z_index = _original_z_index

func play_exit_animation():
	mouse_filter = MOUSE_FILTER_IGNORE
	# Raise z_index, no need to restore since we're going to free it
	z_index = 1000

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.22)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.22)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y + 20, 0.22)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_exit_animation_finished"))

func _on_exit_animation_finished():
	queue_free()
