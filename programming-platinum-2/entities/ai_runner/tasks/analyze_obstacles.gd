class_name AnalyzeObstacles
extends BTAction

@export var obstacle_data_var_name: StringName = "obstacle_data"
@export var required_action_var_name: StringName = "required_action"
@export var target_lane_var_name: StringName = "target_lane"
@export var scan_distance : float = 10.0

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE

	var current_lane            = ai.bt_player.blackboard.get_var("current_lane")
	var lanes_x: Array[float] = ai.lanes_x
	var obstacles               = blackboard.get_var(obstacle_data_var_name, [])
	var closest = null
	var min_dist : float = INF

	# Find closest obstacle in current lane
	for obs in obstacles:
		if obs["lane"] == current_lane and obs["distance"] < min_dist:
			closest = obs
			min_dist = obs["distance"]
			

	if closest == null:
		# No obstacles in the current lane
		blackboard.set_var(required_action_var_name, "None")
		return SUCCESS
		
	# Case for when the ai is still climbing the stairs
	if ai.using_stairs and not ai.is_on_upper_level:
		blackboard.set_var(required_action_var_name, "UseStairs")
		blackboard.set_var(target_lane_var_name, ai.bt_player.blackboard.get_var("current_lane"))
		return SUCCESS

	if closest.node is Gate:
		blackboard.set_var(required_action_var_name, "Jump")
		return SUCCESS
	if closest.node is Stairs:
		var stairs_z           = closest["position"].z
		var found_train: bool        = false
		var found_any_obstacle: bool = false
		for obs in obstacles:
			if obs["lane"] == current_lane and obs["position"].z > stairs_z and obs["position"].z - stairs_z < 5.0:
				found_any_obstacle = true
				if obs.node is Train:
					found_train = true
					break
		# Use stairs if a train is found, or if there is empty space (no obstacle in range)
		if found_train or not found_any_obstacle:
			blackboard.set_var(required_action_var_name, "UseStairs")
			blackboard.set_var(target_lane_var_name, current_lane)
			return SUCCESS

	if closest.node is Train:
		if ai.is_on_upper_level:
			blackboard.set_var(required_action_var_name, "None")
			return SUCCESS
		else:
			print("Train detected")
			pass # Need to avoid or use stairs

	# Try to find any clear lane (other than the current one)
	var best_lane: int = -1
	for i in lanes_x.size():
		if i == current_lane:
			continue
		var blocked: bool = false
		for obs in obstacles:
			if obs["lane"] == i and obs["distance"] < 3.0:
				blocked = true
				break
		if not blocked:
			best_lane = i
			break
	if best_lane != -1:
		blackboard.set_var(required_action_var_name, "ChangeLane")
		blackboard.set_var(target_lane_var_name, best_lane)
		return SUCCESS
	print("best_lane")


	blackboard.set_var(required_action_var_name, "None")
	return SUCCESS
