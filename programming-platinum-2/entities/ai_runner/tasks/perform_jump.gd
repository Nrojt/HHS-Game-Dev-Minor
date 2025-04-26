class_name PerformJump
extends BTAction

@export var nearest_object_var_name: StringName = "nearest_object_distance"
@export var nearest_object_jump_start_distance: float = 3.0

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE

	var closest = blackboard.get_var(nearest_object_var_name, null)
	if closest == null or not closest.has("node"):
		return FAILURE

	var node = closest.node
	if not node or not node.has_method("get_global_position"):
		return FAILURE

	var ai_pos: Vector3 = ai.global_position
	var closest_pos: Vector3 = node.global_position
	var distance: float = ai_pos.distance_to(closest_pos)
	if distance > nearest_object_jump_start_distance:
		return RUNNING

	if ai.is_on_floor():
		ai.velocity.y = ai.jump_velocity
		return SUCCESS

	return RUNNING
