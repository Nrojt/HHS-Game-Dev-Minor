extends RigidBody3D

# TODO potentially add collision check before making static. Theoretically, droppable could become static in the air if it was somehow not moving

@export var stillness_threshold: int = 10
@export var time_until_static: float = 4.0
@export var ground_check_ray_length: float = 0.4

var time_since_moved: float = 0.0
var is_static: bool = false

func _physics_process(delta: float) -> void:
	if is_static:
		return

	var is_moving: bool = linear_velocity.length() > stillness_threshold

	if is_moving:
		time_since_moved = 0.0
	else:
		time_since_moved += delta
		if time_since_moved >= time_until_static:
			make_static()


func make_static():
	is_static = true
	var static_body = StaticBody3D.new()

	# Add to scene tree
	get_parent().add_child(static_body)

	# Set global transform before adding children
	static_body.global_transform = global_transform

	# Copy all relevant children
	for child in get_children():
		if child is CollisionShape3D or child is CollisionPolygon3D or child is Node3D:
			var duplicated_child: Node = child.duplicate()
			static_body.add_child(duplicated_child)

			# Copy transform and owner
			duplicated_child.transform = child.transform
			duplicated_child.owner = static_body

			child.queue_free()
		
	print("Droppable is now static")
	queue_free()
