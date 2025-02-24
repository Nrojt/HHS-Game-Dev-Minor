extends Node

var current_droppable: DroppableBase = null:
	get:
		if (current_droppable != null && current_droppable.is_queued_for_deletion()):
			current_droppable = null
		return current_droppable
	set(value):
		current_droppable = value

var max_height: float = -INF


func _ready() -> void:
	SignalManager.move_current_droppable.connect(_on_move_current_droppable)
	SignalManager.drop_current_droppable.connect(_on_drop_current_droppable)
	SignalManager.player_death.connect(reset_variables)


func _on_move_current_droppable(location: Vector3) -> void:
	if current_droppable and current_droppable.is_holding:
		current_droppable.global_transform.origin = location


func _on_drop_current_droppable() -> void:
	if current_droppable != null and current_droppable.is_holding:
		current_droppable.gravity_scale = 1
		current_droppable.is_holding = false


func calculate_max_height(item: StaticBody3D) -> float:
	var item_height: float = get_object_height(item)
	if item_height > max_height:
		if max_height != -INF:
			SignalManager.update_camera_height.emit(item_height - max_height)
		max_height = item_height
	return max_height


# TODO: figure out his math
# Method generated using generative AI (Deepseek, 2025)
func get_object_height(item: Node3D) -> float:
	var item_max_height: float = 0.0
	var item_min_height: float = 0.0

	for child in item.get_children():
		if child is CollisionShape3D:
			var shape: Shape3D = child.shape
			var global_pos: Vector3 = child.global_transform.origin

			if shape is BoxShape3D:
				var extents: float = shape.size.y / 2
				item_max_height = max(item_max_height, global_pos.y + extents)
				item_min_height = min(item_min_height, global_pos.y - extents)
			elif shape is SphereShape3D:
				var radius: float = shape.radius
				item_max_height = max(item_max_height, global_pos.y + radius)
				item_min_height = min(item_min_height, global_pos.y - radius)
			elif shape is CapsuleShape3D:
				var height: float = shape.height
				var radius: float = shape.radius
				item_max_height = max(item_max_height, global_pos.y + height/2 + radius)
				item_min_height = min(item_min_height, global_pos.y - height/2 - radius)
			elif shape is CylinderShape3D:
				var height: float = shape.height
				var radius: float = shape.radius
				item_max_height = max(item_max_height, global_pos.y + height/2 + radius)
				item_min_height = min(item_min_height, global_pos.y - height/2 - radius)
			elif shape is ConvexPolygonShape3D:
				var points: PackedVector3Array = shape.points
				if points.size() > 0:
					var local_bounds_min: float = points[0].y
					var local_bounds_max: float = points[0].y
					for point in points:
						local_bounds_min = min(local_bounds_min, point.y)
						local_bounds_max = max(local_bounds_max, point.y)
					# Apply scale and rotation from global transform
					var transformed_extents = child.global_transform.basis * Vector3(0, (local_bounds_max - local_bounds_min) / 2, 0)
					var center_offset: float = (local_bounds_max + local_bounds_min) / 2
					item_max_height = max(item_max_height, global_pos.y + center_offset + abs(transformed_extents.y))
					item_min_height = min(item_min_height, global_pos.y + center_offset - abs(transformed_extents.y))
			else:
				print("Unknown shape: ", shape)

	return (item_max_height - item_min_height)


func reset_variables() -> void:
	if current_droppable != null:
		print("droppable null")
		current_droppable.queue_free()
	print("droppable not null") # TODO why is the held one not despawning
	current_droppable = null
	max_height = -INF
