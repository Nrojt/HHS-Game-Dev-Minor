# EngageStairs.gd
class_name EngageStairs
extends BTAction

@export var upper_level_height : float = 4.0

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE
	ai.using_stairs = true
	# Bit hacky, but works
	if ai.global_position.y >= upper_level_height:
		ai.is_on_upper_level = true
		ai.using_stairs = false
		return SUCCESS
	return RUNNING
