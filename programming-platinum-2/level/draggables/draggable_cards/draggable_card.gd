extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/Label

# Array to hold all draggable scenes
@export var DRAGGABLE_SCENES: Array[PackedScene] = [
	preload("uid://7p7ercjif3ja"),
	preload("uid://buutu78g1kur"),
	preload("uid://bkmpcsxb0jjy0")
]

var is_dragging_card: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
var draggable_preview : DraggableBase

# Signal to inform another node when this card starts being dragged
signal card_started_dragging(draggable_scene: PackedScene, card_instance: Control)

func _ready():
	# Select a random draggable scene for this card to represent
	select_random_draggable_scene()

func select_random_draggable_scene():
	if DRAGGABLE_SCENES.is_empty():
		push_error("Error: No draggable scenes defined in DRAGGABLE_SCENES array.")
		title_label.text = "Error"
		return

	var draggable_scene_index = randi_range(0, DRAGGABLE_SCENES.size() - 1)
	var random_scene: PackedScene = DRAGGABLE_SCENES[draggable_scene_index]
	draggable_preview = random_scene.instantiate()

	if draggable_preview:
		title_label.text = draggable_preview.name
	else:
		title_label.text = "Error Loading"
		push_error(
			"Error: Failed to instantiate preview scene: ",
			random_scene.resource_path
		)

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
			# Check if the mouse has moved a significant distance to confirm it's a drag
			if drag_start_position.distance_to(get_global_mouse_position()) > 5: # Use a small threshold
				print("Card is being dragged!")
				# Emit a signal to inform the spawner/manager
				if draggable_preview:
					GameManager.start_dragging_draggable.emit(draggable_preview)
				is_dragging_card = false # Reset dragging state after emitting the signal
