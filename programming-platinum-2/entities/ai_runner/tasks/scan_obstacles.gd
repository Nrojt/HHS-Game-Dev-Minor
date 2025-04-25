class_name ScanObstacles
extends BTAction

@export var lookahead_distance_var_name: StringName = "lookahead_distance"
@export var obstacle_data_var_name: StringName = "obstacle_data"

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE

	var lookahead_distance: float = ai.lookahead_distance
	var lanes_x: Array[float] = ai.lanes_x
	var my_pos: Vector3         = ai.global_position

	var obstacles: Array[Variant] = []
	for obstacle in ai.get_tree().get_nodes_in_group("Obstacles"):
		var obs_pos       = obstacle.global_position
		var lane_idx: int = -1
		var min_dist : float = INF
		for i in lanes_x.size():
			var dist : float = abs(obs_pos.x - lanes_x[i])
			if dist < min_dist:
				min_dist = dist
				lane_idx = i
		var forward_dist = obs_pos.z - my_pos.z
		if forward_dist < 0 and abs(forward_dist) <= lookahead_distance:
			obstacles.append({
			"node": obstacle,
			"lane": lane_idx,
			"distance": abs(forward_dist),
			"position": obs_pos
		})
	blackboard.set_var(obstacle_data_var_name, obstacles)
	return SUCCESS
