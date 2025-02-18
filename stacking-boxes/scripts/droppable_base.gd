extends RigidBody3D
class_name DroppableBase

@export var stillness_threshold: int = 10
@export var time_until_static: float = 4.0
@export var ground_check_additional_ray_length: float = 0.6
@export var raycast_timeout: float = 4.0
@export_flags_3d_physics var ground_collision_layer: int = 1

var time_since_moved: float = 0.0
var time_raycasted: float = 0.0
var is_holding: bool = true
var is_static: bool = false
var ground_ray: RayCast3D

signal spawn_new_enabled

# TODO: Ray cast is not always working, why?


func _ready():
	# Create raycast as child
	ground_ray = RayCast3D.new()
	add_child(ground_ray)
	ground_ray.collision_mask = ground_collision_layer
	ground_ray.exclude_parent = true
	# Calculate ray length based on object height
	ground_ray.target_position = Vector3(0, -get_object_height(), 0)
	ground_ray.enabled = true

func _physics_process(delta: float) -> void:
	if is_static || is_holding:
		return

	# Update raycast position while maintaining world-space orientation
	ground_ray.global_transform = Transform3D.IDENTITY.translated(global_transform.origin)

	var is_moving: bool = linear_velocity.length() > stillness_threshold

	if is_moving:
		time_since_moved = 0.0
		time_raycasted = 0.0
	else:
		time_since_moved += delta
		time_raycasted += delta

		var colliding: bool = ground_ray.is_colliding()
		

		if time_since_moved >= time_until_static and colliding:
			print("Raycast colliding: %s, with: %s" % [colliding, ground_ray.get_collider() if colliding else "nothing"])
			make_static()
		elif time_raycasted >= raycast_timeout:
			print("Raycast timeout - forcing static : ", colliding)
			make_static()

	if global_transform.origin.y < -10:
		enable_new_spawn()

func get_object_height() -> float:
	var max_height: float = 0.0
	var min_height: float = 0.0

	# Check all collision shapes to find vertical bounds
	for child in get_children():
		if child is CollisionShape3D:
			var shape: Shape3D = child.shape
			var global_pos: Vector3 = child.global_transform.origin

			if shape is BoxShape3D:
				var extents: float = shape.size.y / 2
				max_height = max(max_height, global_pos.y + extents)
				min_height = min(min_height, global_pos.y - extents)
			elif shape is SphereShape3D:
				var radius: float = shape.radius
				max_height = max(max_height, global_pos.y + radius)
				min_height = min(min_height, global_pos.y - radius)
			elif shape is CapsuleShape3D:
				var height: float = shape.height
				var radius: float = shape.radius
				max_height = max(max_height, global_pos.y + height/2 + radius)
				min_height = min(min_height, global_pos.y - height/2 - radius)

	# Calculate total height with buffer
	return (max_height - min_height) + ground_check_additional_ray_length

func make_static():
	is_static = true
	var static_body = StaticBody3D.new()

	# Add to scene tree
	get_parent().add_child(static_body)

	# Set global transform before adding children
	static_body.global_transform = global_transform

	# Copy all relevant children
	for child in get_children():
		if child is Node3D and child is not RayCast3D:
			var duplicated_child: Node = child.duplicate()
			
			static_body.add_child(duplicated_child)
			duplicated_child.transform = child.transform
			duplicated_child.owner = static_body
		child.queue_free()
	enable_new_spawn()

# Removing ourselves from the scene
func enable_new_spawn() -> void:
	spawn_new_enabled.emit()
	queue_free()
