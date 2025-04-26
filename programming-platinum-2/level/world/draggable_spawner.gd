extends Node

# Array to hold all draggable scenes
@export var DRAGGABLE_SCENES: Array[PackedScene] = [
	preload("uid://7p7ercjif3ja"),
	preload("uid://buutu78g1kur"),
	preload("uid://bkmpcsxb0jjy0")  
]

func _ready():
	GameManager.game_started.connect(spawn_draggable)
	GameManager.placed_draggable.connect(
		func(drag: Draggable):
			if drag and drag.is_inside_tree():
				remove_child(drag)
			spawn_draggable()
	)

func spawn_draggable() -> void:
	if DRAGGABLE_SCENES.is_empty():
		push_error("Error: No draggable scenes defined in DRAGGABLE_SCENES array.")
		return

	# Pick a random index from the array
	var random_index: int = randi_range(0, DRAGGABLE_SCENES.size() - 1)
	var random_scene: PackedScene = DRAGGABLE_SCENES[random_index]
	var draggable: Draggable = random_scene.instantiate()

	if draggable:
		print("Draggable: " + draggable.name)
		GameManager.current_draggable = draggable
		add_child(draggable)
	else:
		print(
			"Error: Failed to instantiate scene: ",
			random_scene.resource_path
		)
