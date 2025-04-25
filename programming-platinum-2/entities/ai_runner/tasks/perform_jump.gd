# PerformJump.gd
class_name PerformJump
extends BTAction

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE
	if ai.is_on_floor():
		ai.velocity.y = ai.jump_velocity
		return SUCCESS
	return FAILURE
