class_name ScanObstacles
extends BTAction

@export var lookahead_distance_var_name: StringName = "lookahead_distance"
@export var obstacle_data_var_name: StringName = "obstacle_data"

# The maximum squared horizontal distance an obstacle can be from a lane's
@export var max_horizontal_deviation_sq: float = 1.0


# Finds the closest lane index for a given x_position.
# Returns -1 if no lane_x_coords are provided, or if the obstacle is too far
func _get_closest_lane_index(
	obstacle_x_pos: float,
	lane_x_coords: Array[float],
	max_allowed_deviation_sq: float
) -> int:
	if lane_x_coords.is_empty():
		return -1

	var best_lane_idx: int = -1
	var min_found_dist_sq: float = INF

	for i in range(lane_x_coords.size()):
		var lane_center_x: float = lane_x_coords[i]
		var delta_x: float = obstacle_x_pos - lane_center_x
		var current_dist_sq: float = delta_x * delta_x
		if current_dist_sq < min_found_dist_sq:
			min_found_dist_sq = current_dist_sq
			best_lane_idx = i # This is the mathematically closest lane

	# If a closest lane was found and it's within the allowed deviation
	if best_lane_idx != -1 and min_found_dist_sq <= max_allowed_deviation_sq:
		return best_lane_idx
	
	# Otherwise, no lane is suitable (either no lanes, or closest is too far)
	return -1


func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		push_error("ScanObstacles: Agent is not an AiRunner.")
		return FAILURE

	var current_lookahead_distance: float = ai.lookahead_distance
	var lane_x_positions: Array[float] = ai.lanes_x
	var ai_position: Vector3 = ai.global_position

	if lane_x_positions.is_empty():
		push_error("ScanObstacles: AI lane data (lanes_x) is empty.")
		blackboard.set_var(obstacle_data_var_name, [])
		return FAILURE

	var detected_obstacles: Array[Dictionary] = []

	var obstacle_nodes_in_group: Array[Node] = ai.get_tree().get_nodes_in_group("Obstacles")
	if obstacle_nodes_in_group.is_empty():
		return RUNNING

	for obstacle_node_variant in obstacle_nodes_in_group:
		var obstacle_node := obstacle_node_variant as Node3D
		if not is_instance_valid(obstacle_node):
			push_warning(
				"ScanObstacles: Found an invalid or freed node in 'Obstacles' group. Skipping."
			)
			continue

		var obstacle_position: Vector3 = obstacle_node.global_position

		var lane_index: int = _get_closest_lane_index(
			obstacle_position.x,
			lane_x_positions,
			self.max_horizontal_deviation_sq # Use the exported threshold
		)

		if lane_index == -1:
			# Obstacle is not considered to be in any lane
			if OS.is_debug_build():
				push_warning(
					"ScanObstacles: Obstacle at %s (X: %f) was not assigned to any lane "
					% [str(obstacle_position), obstacle_position.x]
					+ "or is too far horizontally from lane centers. Max deviation sq: %f"
					% self.max_horizontal_deviation_sq
				)
			continue # Skip this obstacle

		var z_distance: float = ai_position.z - obstacle_position.z

		if z_distance >= 0.0 and z_distance <= current_lookahead_distance:
			detected_obstacles.append({
				"node": obstacle_node,
				"lane": lane_index,
				"distance": z_distance,
				"position": obstacle_position
			})

	blackboard.set_var(obstacle_data_var_name, detected_obstacles)
	return SUCCESS
