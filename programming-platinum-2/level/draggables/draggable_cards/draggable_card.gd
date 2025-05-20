class_name DraggableCard extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/Label

var draggable_preview : DraggableBase = null

var is_dragging_card: bool = false
var drag_start_position: Vector2 = Vector2.ZERO

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
				print("Card pressed. Potential drag started.")
			elif !event.pressed and is_dragging_card:
				# End of a drag or just a click
				is_dragging_card = false

	if event is InputEventMouseMotion:
		if is_dragging_card:
			# Check if the mouse has moved past a threshold distance to confirm it's a drag
			if drag_start_position.distance_to(get_global_mouse_position()) > 5:
				print("Card is being dragged!")
				# Emit a signal with the associated preview
				if draggable_preview:
					GameManager.start_dragging_draggable.emit(self, draggable_preview)
				is_dragging_card = false
