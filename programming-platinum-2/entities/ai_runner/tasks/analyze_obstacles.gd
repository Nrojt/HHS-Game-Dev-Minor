class_name AnalyzeObstacles
extends BTAction

@export var obstacle_data_var_name: StringName = "obstacle_data"
@export var required_action_var_name: StringName = "required_action"
@export var target_lane_var_name: StringName = "target_lane"
@export var nearest_object_var_name: StringName = "nearest_object_distance"
@export var scan_distance: float = 20.0
@export var lookahead_steps: int = 3
@export var danger_threshold: float = 3.0
@export var lane_change_safety_bias: float = 1.5
enum LaneState { CLEAR, JUMP, STAIRS, BLOCKED }


# Returns all obstacles in a given lane.
func _get_lane_obstacles(lane: int, obstacles: Array) -> Array:
	var result: Array = []
	for o in obstacles:
		if o["lane"] == lane:
			result.append(o)
	return result


# Sorts a list of obstacles in-place by their distance (ascending).
func _sort_obstacles_by_distance(obstacles: Array) -> void:
	obstacles.sort_custom(func(a, b): return a["distance"] < b["distance"])


# Returns true if there is a Train obstacle ahead of position z in the given lane.
func _is_train_ahead(obstacles: Array, lane: int, z: float) -> bool:
	for o in obstacles:
		if (
		o["lane"] == lane
		and o["position"].z > z
		and o["position"].z - z < 5.0
		and o.node is Train
		):
			return true
	return false


# Returns true if there is any obstacle ahead of position z in the given lane.
func _is_any_obstacle_ahead(obstacles: Array, lane: int, z: float) -> bool:
	for o in obstacles:
		if o["lane"] == lane and o["position"].z > z and o["position"].z - z < 5.0:
			return true
	return false


# Returns the safety score for a lane: the distance to the first dangerous obstacle, or scan_distance if clear.
func _get_lane_safety(lane: int, obstacles: Array, ai: AiRunner) -> float:
	var obs: Array = _get_lane_obstacles(lane, obstacles)
	_sort_obstacles_by_distance(obs)
	for i in range(min(lookahead_steps, obs.size())):
		var o = obs[i]
		if !is_instance_valid(o):
			return FAILURE
		if o["distance"] > scan_distance:
			return scan_distance # No danger found, return max safety
		# An obstacle is dangerous if it's too close OR it's a train and AI is on ground level
		if o["distance"] < danger_threshold or (o.node is Train and !ai.is_on_upper_level):
			return o["distance"] # Safety is distance to first danger
	return scan_distance # No danger found within lookahead, return max safety


# Returns the closest obstacle in a lane, or null if none.
func _get_closest_obstacle_in_lane(lane: int, obstacles: Array) -> Variant:
	var obs_in_lane: Array = _get_lane_obstacles(lane, obstacles)
	_sort_obstacles_by_distance(obs_in_lane)
	return obs_in_lane[0] if obs_in_lane.size() > 0 else null


func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		push_error("AnalyzeObstacles: Agent is not AiRunner")
		return FAILURE

	var current_lane = ai.bt_player.blackboard.get_var("current_lane", -1)
	if current_lane == -1:
		push_error("AnalyzeObstacles: current_lane not set in blackboard")
		return FAILURE

	var lanes_x: Array[float] = ai.lanes_x
	print("lanes_x: ", lanes_x)
	if lanes_x.is_empty():
		push_error("AnalyzeObstacles: ai.lanes_x is empty")
		return FAILURE
	if current_lane < 0 or current_lane >= lanes_x.size():
		push_error(
			"AnalyzeObstacles: current_lane index out of bounds: ", current_lane
		)
		return FAILURE

	var obstacles: Array = blackboard.get_var(obstacle_data_var_name, [])

	# Calculate the safety of each lane
	var safety: Array[Variant] = []
	for i in lanes_x.size():
		safety.append(_get_lane_safety(i, obstacles, ai))

	# Checking the closest obstacle in the current lane
	var closest = _get_closest_obstacle_in_lane(current_lane, obstacles)
	var state: int = LaneState.CLEAR
	if closest:
		# Check for if the ai is still climbing stairs
		if ai.using_stairs and not ai.is_on_upper_level:
			blackboard.set_var(required_action_var_name, "UseStairs")
			blackboard.set_var(target_lane_var_name, current_lane)
			return SUCCESS # Continue using stairs

		if closest.node is Gate:
			state = LaneState.JUMP
		elif closest.node is Stairs:
			var stairs_z = closest["position"].z
			# Check if path after stairs is clear
			var found_train: bool = _is_train_ahead(
				obstacles, current_lane, stairs_z
			)
			var found_any: bool = _is_any_obstacle_ahead(
				obstacles, current_lane, stairs_z
			)
			# Use stairs if train is ahead OR nothing is ahead. Blocked otherwise.
			state = (
			LaneState.STAIRS
			if found_train or not found_any
			else LaneState.BLOCKED
			)
			# If blocked by non-train after stairs, but stairs are far, treat as clear for now
			if (
			closest["distance"] >= danger_threshold
			and state == LaneState.BLOCKED
			):
				state = LaneState.CLEAR
		elif closest.node is Train and ! ai.is_on_upper_level: # Train on ground level blocks
			state = LaneState.BLOCKED
		elif closest["distance"] < danger_threshold: # Any close obstacle blocks
			state = LaneState.BLOCKED

	# Setting the final action
	var action: String = "None"
	var target_lane = current_lane # Default target is current lane

	if state == LaneState.JUMP:
		action = "Jump"
		blackboard.set_var(nearest_object_var_name, closest)
	elif state == LaneState.STAIRS:
		action = "UseStairs"
		# Target lane for stairs is always the current lane
		target_lane = current_lane
	elif state == LaneState.BLOCKED:
		action = "None" # Blocked, default action is None, try to change lanes below

	# Lane Changing
	var best_other_lane: int = -1
	var max_other_safety: float = -INF

	# Find the best alternative lane
	for i in lanes_x.size():
		if i == current_lane:
			continue
		if safety[i] > max_other_safety:
			max_other_safety = safety[i]
			best_other_lane = i

	var should_consider_change: bool = false
	if best_other_lane != -1: # Check if there is an alternative lane
		if state == LaneState.BLOCKED:
			# If blocked, consider changing if any other lane is safer
			if max_other_safety > safety[current_lane]:
				should_consider_change = true
		else:
			# If not blocked, consider changing only if the best other lane is safer
			if max_other_safety > safety[current_lane] + lane_change_safety_bias:
				should_consider_change = true

	var is_changing_lanes = blackboard.get_var("is_changing_lanes", false)
	# Execute change only if considered AND the target lane is safe enough
	if should_consider_change and max_other_safety > danger_threshold and not is_changing_lanes:
		action = "ChangeLane"
		target_lane = best_other_lane

	# Blackboard variables
	blackboard.set_var(required_action_var_name, action)

	# Only set target_lane if the action requires it
	if action == "ChangeLane":
		blackboard.set_var(target_lane_var_name, target_lane)
	elif action == "UseStairs":
		blackboard.set_var(target_lane_var_name, current_lane)

	var final_target = target_lane if action == "ChangeLane" else current_lane
	if action == "UseStairs":
		final_target = current_lane # Explicitly show current lane for stairs

	# Debug print
	print(
		"Analyze: lane %d, state %s, safety %s, action %s, target %d"
		% [
		current_lane,
		LaneState.keys()[state],
		safety,
		action,
		final_target,
		]
	)

	return SUCCESS
