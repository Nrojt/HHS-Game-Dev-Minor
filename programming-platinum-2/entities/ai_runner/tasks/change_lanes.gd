class_name ChangeLanes
extends BTAction

@export var target_lane_var_name: StringName = "target_lane"

# TODO: sometimes the enemy vibrates like crazy during moving, never really arriving at its possition. Often happends when an obstacle is in the way of its path

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE

	var target_lane = blackboard.get_var(target_lane_var_name, ai.bt_player.blackboard.get_var("current_lane"))
	var lanes_x: Array[float] = ai.lanes_x
	var target_x: float = lanes_x[target_lane]
	var dx: float = target_x - ai.global_position.x

	var arrived_x = abs(dx) < 0.05

	if arrived_x:
		ai.global_position.x = target_x
		ai.velocity.x = 0
		ai.bt_player.blackboard.set_var("current_lane", target_lane)
		return SUCCESS

	var direction_x = sign(dx)
	ai.velocity.x = direction_x * ai.lane_switch_speed
	return RUNNING
