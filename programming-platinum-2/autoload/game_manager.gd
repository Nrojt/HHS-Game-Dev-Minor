extends Node

signal placed_draggable(placed_draggable : Draggable)

var current_draggable : Draggable:
	set(value):
		if value == null:
			placed_draggable.emit(current_draggable)
		current_draggable = value
