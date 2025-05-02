class_name ChangeLanes
extends BTAction

@export var target_lane_var_name: StringName = "target_lane"

func _tick(delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE

	var target_lane = blackboard.get_var(target_lane_var_name, ai.bt_player.blackboard.get_var("current_lane"))
	var lanes_x: Array[float] = ai.lanes_x
	var target_x: float = lanes_x[target_lane]
	var dx: float = target_x - ai.global_position.x

	var arrival_threshold := 0.05

	if abs(dx) < arrival_threshold:
		ai.global_position.x = target_x
		ai.velocity.x = 0
		blackboard.set_var("current_lane", target_lane)
		blackboard.set_var("is_changing_lanes", false)
		return SUCCESS

	var direction_x = sign(dx)
	var max_move: float = ai.lane_switch_speed * delta

	# Clamp movement to not overshoot the target
	if abs(dx) < max_move:
		ai.velocity.x = dx / delta
	else:
		ai.velocity.x = direction_x * ai.lane_switch_speed

	return RUNNING
