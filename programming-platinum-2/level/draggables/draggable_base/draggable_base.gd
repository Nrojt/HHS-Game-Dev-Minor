extends Node3D

# TODO: check collisions with world as well

## Set to true when the object is placed and should stop following.
@export var placed := false
## The plane to project the mouse position onto.
@export var projection_plane := Plane(Vector3.UP, 0)

func _process(delta: float) -> void:
	if not placed:
		var camera : Camera3D = get_viewport().get_camera_3d()
		if not camera:
			push_error("No 3D camera found in viewport!")
			return # Cannot proceed without a camera

		var mouse_pos := get_viewport().get_mouse_position()

		# Make the draggable follow the mouse
		follow_mouse_on_plane(camera, mouse_pos)


#  Places the node where the mouse ray intersects the projection_plane
func follow_mouse_on_plane(camera: Camera3D, mouse_pos: Vector2) -> void:
	# Get the ray origin and direction from the camera through the mouse
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_normal := camera.project_ray_normal(mouse_pos)

	# Find the intersection point with the defined plane
	# TODO sometimes null
	var intersection_point: Vector3 = projection_plane.intersects_ray(ray_origin, ray_normal)

	# If the ray intersects the plane, move the node there
	if intersection_point != null:
		global_position = intersection_point


func follow_mouse_with_raycast(camera: Camera3D, mouse_pos: Vector2, max_distance: float = 1000.0) -> void:
	var space_state := get_world_3d().direct_space_state
	if not space_state:
		printerr("Cannot get physics space state.")
		return

	var ray_origin : Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_normal : Vector3 = camera.project_ray_normal(mouse_pos)
	var ray_end : Vector3 = ray_origin + ray_normal * max_distance

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	# TODO collision masks
	var result : Dictionary = space_state.intersect_ray(query)

	# Check if the dictionary is not empty (aka hit something)
	if result: 
		global_position = result.position
