class_name CanInitiateJump
extends BTAction

@export var nearest_object_var_name: StringName = "nearest_object_distance"
@export var nearest_object_jump_start_distance: float = 3.0


func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		# Can't evaluate conditions without an AI
		return FAILURE

	# AI must not be on an upper level to perform a standard jump.
	if ai.is_on_upper_level:
		ai.suppress_z_correction = false # Ensure correction is allowed
		return FAILURE

	# AI must be on the floor to initiate a jump.
	if not ai.is_on_floor():
		ai.suppress_z_correction = false # Ensure correction is allowed
		return FAILURE

	# Valid obstacle data must be present.
	var closest_obstacle_data = blackboard.get_var(
		nearest_object_var_name, null
	)
	if closest_obstacle_data == null or not ("distance" in closest_obstacle_data):
		ai.suppress_z_correction = false # Ensure correction is allowed
		return FAILURE

	var z_dist_to_obstacle: float = closest_obstacle_data["distance"]

	# Condition 4: AI must be close enough to the obstacle.
	if z_dist_to_obstacle > nearest_object_jump_start_distance:
		ai.suppress_z_correction = false # Ensure correction is allowed
		return FAILURE

	# All conditions met, ready to jump.
	ai.suppress_z_correction = false
	return SUCCESS
