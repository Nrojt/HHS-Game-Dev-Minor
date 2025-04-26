extends Node3D

@export var section_scene: PackedScene
@export var initial_spawn_count: int = 7
@export var movement_direction: Vector3 = Vector3.BACK

var _sections: Array[EmptySection] = []
var _last_section: EmptySection

func _ready() -> void:
	movement_direction = movement_direction.normalized()
	for _i in range(initial_spawn_count):
		_spawn_section()

func _physics_process(_delta: float) -> void:
	if _sections.is_empty():
		return

	var camera := get_viewport().get_camera_3d()
	if not camera:
		push_error("No 3D camera found in viewport!")
		return

	var first_section: EmptySection = _sections[0]
	var end_pos: Vector3 = first_section.end_marker.global_position

	# check if the first section is out of view
	if 	_is_out_of_view(camera, end_pos):
		_sections.remove_at(0)
		first_section.queue_free()
		_spawn_section()

func _is_out_of_view(camera: Camera3D, point: Vector3) -> bool:
	# check if the point is behind the camera
	if camera.is_position_behind(point):
		return true
	var screen_pos: Vector2 = camera.unproject_position(point)
	var rect: Rect2 = get_viewport().get_visible_rect()
	return not rect.has_point(screen_pos)

func _spawn_section() -> void:
	var instance := section_scene.instantiate() as EmptySection
	add_child(instance)
	if _last_section:
		instance.global_position = _last_section.end_marker.global_position
	else:
		instance.global_position = global_position
	_sections.append(instance)
	_last_section = instance
