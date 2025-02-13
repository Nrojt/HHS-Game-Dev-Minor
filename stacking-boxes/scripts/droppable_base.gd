extends RigidBody3D

@export var stillness_threshold: int = 10
@export var time_until_static: float = 2.0

var time_since_moved: float = 0.0
var is_static: bool = false

func _physics_process(delta: float) -> void:
	if is_static:
		return

	if linear_velocity.length() > stillness_threshold:
		time_since_moved = 0.0
	else:
		time_since_moved += delta
		if time_since_moved >= time_until_static:
			make_static()

func make_static():
	is_static = true
	var static_body = StaticBody3D.new()

	# Add to scene tree FIRST before setting global properties
	get_parent().add_child(static_body)

	# Now set the global transform correctly
	static_body.global_transform = global_transform

	# Copy collision shapes
	for child in get_children():
		if child is CollisionShape3D or child is CollisionPolygon3D or child is Node3D:
			var duplicated_child: Node = child.duplicate()
			static_body.add_child(duplicated_child)
			child.queue_free()

	queue_free()
