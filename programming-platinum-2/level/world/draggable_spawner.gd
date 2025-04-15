extends Node

const STAIR_SCENE = preload("uid://7p7ercjif3ja")

func _ready():
	spawn_draggable()
	GameManager.placed_draggable.connect(
		func(drag : Draggable): 
			remove_child(drag)
			spawn_draggable()
	)

func spawn_draggable()-> void:
	var draggable : Draggable = STAIR_SCENE.instantiate()
	GameManager.current_draggable = draggable
	add_child(draggable)
