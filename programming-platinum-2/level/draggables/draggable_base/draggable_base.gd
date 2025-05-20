class_name DraggableBase
extends Node3D

@export_flags_3d_physics var collision_mask := 1

@export var placed := false
@export var projection_plane := Plane(Vector3.UP, 0)
@export var default_ray_distance := 10.0
@export var draggable_y_offset := 2.0

var lane_index := -1

@onready var static_body : StaticBody3D = $StaticBody3D

# Track previous draggable state
var _was_held := false

func _ready():
	# Initialize the draggable state
	_was_held = Input.is_action_pressed("hold_draggable")

func _process(_delta: float) -> void:
	if not placed:
		# Dragging logic
		var camera: Camera3D = get_viewport().get_camera_3d()
		if not camera:
			push_error("No 3D camera found in viewport!")
			return

		var mouse_pos := get_viewport().get_mouse_position()
		
		# Physics raycast
		if not _follow_mouse_with_raycast(camera, mouse_pos):
			# Fall back to plane projection if no collision
			_follow_mouse_on_plane(camera, mouse_pos)
			
		# Setting the global Y a bit higher
		global_position.y += draggable_y_offset

		# Mouse release detection
		var is_draggable_held: bool = Input.is_action_pressed("hold_draggable")
		if _was_held and not is_draggable_held:
			# Draggable was just released
			print("Let go of draggable")
			GameManager.end_dragging_draggable.emit(self)
		_was_held = is_draggable_held

func set_collision_layer(_collision_layer : int):
	var collision_shape : CollisionShape3D = static_body.get_node("CollisionShape3D")
	print(collision_shape.disabled)
	if collision_shape:
		collision_shape.disabled = false
		static_body.collision_layer = _collision_layer
	else:
		print("No collision shape found.")

func _follow_mouse_on_plane(camera: Camera3D, mouse_pos: Vector2) -> void:
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_normal: Vector3 = camera.project_ray_normal(mouse_pos)
	var intersection_point  = projection_plane.intersects_ray(ray_origin, ray_normal)

	if intersection_point != null:
		global_position = intersection_point
	else:
		# Fallback: Use default distance when no plane intersection
		global_position = ray_origin + ray_normal * default_ray_distance

func _follow_mouse_with_raycast(
	camera: Camera3D, 
	mouse_pos: Vector2, 
	max_distance: float = 1000.0
) -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	if not space_state:
		push_error("Cannot get physics space state.")
		return false

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_normal: Vector3 = camera.project_ray_normal(mouse_pos)
	var ray_end: Vector3 = ray_origin + ray_normal * max_distance

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = collision_mask
	var result: Dictionary = space_state.intersect_ray(query)

	if not result.is_empty():
		global_position = result.position
		return true
	return false
