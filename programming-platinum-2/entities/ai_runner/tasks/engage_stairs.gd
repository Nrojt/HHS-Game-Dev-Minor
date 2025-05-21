# EngageStairs.gd
class_name EngageStairs
extends BTAction

@export var upper_level_height : float = 4.0

func _enter():
	blackboard.set_var("is_jumping", false)
	blackboard.set_var("is_on_upper_level", false)
	var ai: AiRunner = agent as AiRunner
	if ai:
		ai.suppress_z_correction = false
	else:
		push_error("EngageStairs: Agent is not AiRunner")

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE
	ai.using_stairs = true
	# Bit hacky, but works
	if ai.global_position.y >= upper_level_height:
		ai.is_on_upper_level = true
		ai.using_stairs = false
		# Reset velocity
		ai.velocity.z = 0.0
		ai.velocity.y = clamp(ai.velocity.y, -ai.jump_velocity, 0.0)
	
		return SUCCESS
	return RUNNING

