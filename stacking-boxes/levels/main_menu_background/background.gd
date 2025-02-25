extends Node

@export var drop_location: Vector3


func _process(delta):
	if GameManager.current_droppable == null:
		SignalManager.spawn_droppable.emit(drop_location)
		SignalManager.drop_current_droppable.emit()
