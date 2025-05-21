extends Node3D

@export var section_scene: PackedScene
@export var initial_spawn_count: int = 7

var _sections: Array[EmptySection] = []
var _last_section: EmptySection
var _ai_runner: Node3D
var _currently_ai_restricted_sections: Array[EmptySection] = []

const SECTION_DEPTH: float = 10.0

func _ready() -> void:
	_ai_runner = get_parent().get_node_or_null("AiRunner")
	if not _ai_runner:
		push_error(
			"AiRunner node not found by SectionSpawner! Ensure AiRunner is a child of World."
		)

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
	# end_marker is at local (0,0,-SECTION_DEPTH) relative to section origin.
	# This global position represents the "back" of the section.
	var back_of_first_section_global_pos: Vector3 = (
		first_section.end_marker.global_position
	)

	if _is_out_of_view(camera, back_of_first_section_global_pos):
		var removed_section: EmptySection = _sections.pop_front()
		if _currently_ai_restricted_sections.has(removed_section):
			_currently_ai_restricted_sections.erase(removed_section)
		removed_section.queue_free()
		_spawn_section()

	if _ai_runner:
		_update_ai_restricted_sections()


func _is_out_of_view(camera: Camera3D, point: Vector3) -> bool:
	# Check if the point is behind the camera's near plane
	if camera.is_position_behind(point):
		return true
	# Check if the point is outside the camera's view on the screen
	var screen_pos: Vector2 = camera.unproject_position(point)
	var rect: Rect2 = get_viewport().get_visible_rect()
	return not rect.has_point(screen_pos)


func _spawn_section() -> void:
	if not section_scene:
		push_error("Section scene is not set in SectionSpawner.")
		return

	var instance := section_scene.instantiate() as EmptySection
	add_child(instance)
	if _last_section:
		instance.global_position = _last_section.end_marker.global_position
	else:
		instance.global_position = global_position

	_sections.append(instance)
	_last_section = instance


func _update_ai_restricted_sections() -> void:
	if not _ai_runner:
		if not _currently_ai_restricted_sections.is_empty():
			for section in _currently_ai_restricted_sections:
				section.set_ai_restricted_by_spawner(false)
			_currently_ai_restricted_sections.clear()
		return

	var new_restricted_set: Array[EmptySection] = []
	var ai_pos_z: float = _ai_runner.global_position.z
	var current_section_idx: int = -1

	for i in range(_sections.size()):
		var section: EmptySection = _sections[i]
		var section_front_z: float = section.global_position.z
		var section_back_z: float = section.global_position.z - SECTION_DEPTH

		if section_back_z <= ai_pos_z and ai_pos_z < section_front_z:
			current_section_idx = i
			break

	if current_section_idx != -1:
		new_restricted_set.append(_sections[current_section_idx])
		var next_section_to_arrive_idx: int = current_section_idx + 1
		if next_section_to_arrive_idx < _sections.size():
			new_restricted_set.append(_sections[next_section_to_arrive_idx])

	var sections_to_unrestrict: Array[EmptySection] = []
	for old_restricted_section in _currently_ai_restricted_sections:
		if not new_restricted_set.has(old_restricted_section):
			sections_to_unrestrict.append(old_restricted_section)

	for section_to_modify in sections_to_unrestrict:
		section_to_modify.set_ai_restricted_by_spawner(false)

	var sections_to_restrict: Array[EmptySection] = []
	for new_restricted_section in new_restricted_set:
		if not _currently_ai_restricted_sections.has(new_restricted_section):
			sections_to_restrict.append(new_restricted_section)

	for section_to_modify in sections_to_restrict:
		section_to_modify.set_ai_restricted_by_spawner(true)

	_currently_ai_restricted_sections = new_restricted_set
