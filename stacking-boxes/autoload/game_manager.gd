extends Node

var current_droppable: DroppableBase = null

func _ready() -> void:
	SignalManager.move_current_droppable.connect(_on_move_current_droppable)
	SignalManager.drop_current_droppable.connect(_on_drop_current_droppable)
	
func _on_move_current_droppable(location: Vector3) -> void:
	if current_droppable and current_droppable.is_holding:
		current_droppable.global_transform.origin = location
	else:
		print("No droppable to move")
		
func _on_drop_current_droppable() -> void:
	if current_droppable:
		current_droppable.gravity_scale = 1
		current_droppable.is_holding = false
	else:
		print("No droppable to drop")