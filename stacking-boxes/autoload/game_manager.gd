extends Node

var current_droppable: DroppableBase = null
var max_height: float = -INF


func _ready() -> void:
	SignalManager.move_current_droppable.connect(_on_move_current_droppable)
	SignalManager.drop_current_droppable.connect(_on_drop_current_droppable)


func _on_move_current_droppable(location: Vector3) -> void:
	if current_droppable and current_droppable.is_holding:
		current_droppable.global_transform.origin = location


func _on_drop_current_droppable() -> void:
	if current_droppable and current_droppable.is_holding:
		current_droppable.gravity_scale = 1
		current_droppable.is_holding = false


# This function calculates the maximum height of the pile from the items in the "pile_items" group.
func get_max_pile_height_unkown() -> float:
	for item in get_tree().get_nodes_in_group("pile_items"):
		if item is StaticBody3D:
			calculate_max_height(item)
	print(max_height)

	return max_height


# TODO: Actually calculate the height of the pile, dont just take the origin (thats in the middle)
func calculate_max_height(item: StaticBody3D) -> float:
	var item_height = item.global_transform.origin.y
	if item_height > max_height:
		max_height = item_height
	return max_height