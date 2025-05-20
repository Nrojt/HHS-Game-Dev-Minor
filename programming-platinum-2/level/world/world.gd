extends Node3D

func _ready():
	GameManager.placed_draggable.connect(_remove_draggable)
	GameManager.end_dragging_draggable.connect(_remove_draggable)
	GameManager.start_dragging_draggable.connect(_spawn_draggable)

func _spawn_draggable(draggable : DraggableBase) -> void:
	print("Spawing")
	if draggable:
		print("Draggable: " + draggable.name)
		GameManager.current_draggable = draggable
		print(GameManager.current_draggable)
		add_child(draggable)
		draggable.show()

func _remove_draggable(draggable : DraggableBase) -> void:
	if draggable and draggable.is_inside_tree():
		GameManager.current_draggable = null
		remove_child(draggable)
