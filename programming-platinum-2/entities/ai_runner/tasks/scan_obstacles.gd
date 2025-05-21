class_name ScanObstacles
extends BTAction

@export var lookahead_distance_var_name: StringName = "lookahead_distance"
@export var obstacle_data_var_name: StringName = "obstacle_data"

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		push_error("ScanObstacles: Agent is not AiRunner")
		return FAILURE

	var lookahead_distance: float = ai.lookahead_distance
	var lanes_x: Array[float] = ai.lanes_x
	var my_pos: Vector3 = ai.global_position

	if lanes_x.is_empty():
		push_error("ScanObstacles: ai.lanes_x is empty.")
		blackboard.set_var(obstacle_data_var_name, [])
		return FAILURE

	var obstacles: Array[Variant] = []
	for obstacle_node in ai.get_tree().get_nodes_in_group("Obstacles"):
		if not is_instance_valid(obstacle_node):
			push_warning("ScanObstacles: Found an invalid node in 'Obstacles' group.")
			continue

		var obs_pos: Vector3 = obstacle_node.global_position
		var lane_idx: int = -1
		var min_lane_dist_sq: float = INF

		# Determine the obstacle's lane
		for i in range(lanes_x.size()):
			var dist_x: float = obs_pos.x - lanes_x[i]
			var current_lane_dist_sq = dist_x * dist_x
			if current_lane_dist_sq < min_lane_dist_sq:
				min_lane_dist_sq = current_lane_dist_sq
				lane_idx = i
		
		# Check if the obstacle is within the lane width
		if lane_idx == -1: # Should not happen if lanes_x is not empty
			push_warning("ScanObstacles: Could not determine lane for obstacle at %s" % str(obs_pos))
			continue

		# Calculate distance in Z
		# The 'distance' should be positive for approaching obstacles.
		var z_distance_to_ai: float = my_pos.z - obs_pos.z

		# Only consider obstacles that are at or in front of the AI (in terms of Z)
		# and within the lookahead_distance.
		if z_distance_to_ai >= 0 and z_distance_to_ai <= lookahead_distance:
			obstacles.append({
				"node": obstacle_node,
				"lane": lane_idx,
				"distance": z_distance_to_ai, # abs distance in Z
				"position": obs_pos
			})

	blackboard.set_var(obstacle_data_var_name, obstacles)
	return SUCCESS
