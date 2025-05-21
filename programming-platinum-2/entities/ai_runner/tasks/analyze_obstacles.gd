class_name AnalyzeObstacles
extends BTAction

@export var obstacle_data_var_name: StringName = "obstacle_data"
@export var required_action_var_name: StringName = "required_action"
@export var target_lane_var_name: StringName = "target_lane"
@export var nearest_object_var_name: StringName = "nearest_object_distance"
@export var scan_distance: float = 20.0
@export var unit_safety_check_size: float = 5.0
@export var lookahead_steps: int = 3
@export var danger_threshold: float = 3.0
@export var immediate_block_threshold: float = 1.5 # NEW: blocks if any obstacle is this close
@export var lane_change_safety_bias: float = 1.5
# Threshold for checking immediate obstacles in the target lane for a switch
@export var immediate_side_collision_threshold: float = 2.0

enum LaneState { CLEAR, JUMP, STAIRS, BLOCKED }


# Sorts a list of obstacles in-place by their distance (ascending).
func _sort_obstacles_by_distance(obstacles: Array) -> void:
	obstacles.sort_custom(func(a, b): return a["distance"] < b["distance"])

# Preprocesses all obstacles, grouping and sorting them by lane.
func _preprocess_obstacles_by_lane(all_obstacles: Array, num_lanes: int) -> Dictionary:
	var obstacles_by_lane: Dictionary = {}
	for i in range(num_lanes):
		obstacles_by_lane[i] = []

	for o in all_obstacles:
		if not ("lane" in o and o["lane"] is int):
			push_warning("AnalyzeObstacles: Obstacle missing or invalid 'lane' data.")
			continue
		var lane: int = o["lane"]
		if lane >= 0 and lane < num_lanes:
			obstacles_by_lane[lane].append(o)
		else:
			push_warning("AnalyzeObstacles: Obstacle has out-of-bounds lane index: %d" % lane)
	for lane_idx in obstacles_by_lane:
		_sort_obstacles_by_distance(obstacles_by_lane[lane_idx])
	return obstacles_by_lane


# Returns the closest obstacle from a pre-sorted list for a lane.
func _get_closest_obstacle_from_sorted_list(sorted_lane_obstacles: Array) -> Variant:
	return sorted_lane_obstacles[0] if not sorted_lane_obstacles.is_empty() else null

# Checks if a Train obstacle is ahead of z_ref in the given sorted lane obstacles.
func _is_train_ahead_on_lane(sorted_lane_obstacles: Array, z_ref: float) -> bool:
	for o in sorted_lane_obstacles:
		if not is_instance_valid(o["node"]):
			continue # Skip invalid nodes
		if o["position"].z <= z_ref:
			continue
		if o["position"].z - z_ref >= unit_safety_check_size:
			break # Sorted list, no need to check further
		if o["node"] is Train:
			return true
	return false


# Checks if any obstacle is ahead of z_ref in the given sorted lane obstacles.
func _is_any_obstacle_ahead_on_lane(sorted_lane_obstacles: Array, z_ref: float) -> bool:
	for o in sorted_lane_obstacles:
		if not is_instance_valid(o["node"]):
			continue # Skip invalid nodes
		if o["position"].z <= z_ref:
			continue
		if o["position"].z - z_ref >= unit_safety_check_size:
			break  # Sorted list, no need to check further
		return true # Any obstacle found
	return false


# Calculates the safety score for a lane based on its sorted obstacles.
func _calculate_lane_safety_score(sorted_lane_obstacles: Array, ai: AiRunner) -> float:
	# Check for ground-level trains first (within scan_distance)
	if not ai.is_on_upper_level:
		for o in sorted_lane_obstacles:
			if not is_instance_valid(o["node"]):
				push_warning("AnalyzeObstacles: Invalid obstacle node in train check.")
				return 0.0 # Max danger
			if o["distance"] > scan_distance:
				break
			if o["node"] is Train:
				return o["distance"]
	# Check other obstacles up to lookahead_steps or scan_distance
	var obstacles_to_check_count = min(lookahead_steps, sorted_lane_obstacles.size())
	for i in range(obstacles_to_check_count):
		var o = sorted_lane_obstacles[i]
		if not is_instance_valid(o["node"]):
			push_warning("AnalyzeObstacles: Invalid obstacle node in general check.")
			return 0.0 # Max danger
		if o["distance"] > scan_distance:
			return scan_distance
		if o["node"] is Gate:
			continue
		if o["distance"] < danger_threshold:
			return o["distance"]
	return scan_distance # Lane is clear or safe enough up to scan_distance

# Checks if switching to the target lane is immediately safe from collisions.
func _is_switch_to_lane_immediately_safe(target_lane_idx: int, obstacles_by_lane: Dictionary, ai: AiRunner) -> bool:
	var target_lane_obstacles: Array = obstacles_by_lane.get(target_lane_idx, [])
	var closest_in_target = _get_closest_obstacle_from_sorted_list(target_lane_obstacles)
	if closest_in_target:
		if not is_instance_valid(closest_in_target["node"]):
			push_warning("AnalyzeObstacles: Invalid node in target lane %d for switch check." % target_lane_idx)
			return false
		if closest_in_target["distance"] < immediate_side_collision_threshold:
			var obs_node = closest_in_target["node"]
			var obs_is_upper: bool = (
				obs_node.has_meta("is_upper_level_obstacle")
				and obs_node.get_meta("is_upper_level_obstacle")
			)
			# Collision if AI and obstacle are on the same level
			if (ai.is_on_upper_level and obs_is_upper) or (not ai.is_on_upper_level and not obs_is_upper):
				return false
	return true

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		push_error("AnalyzeObstacles: Agent is not AiRunner")
		return FAILURE

	var current_lane: int = ai.bt_player.blackboard.get_var("current_lane", -1)
	if current_lane == -1:
		push_error("AnalyzeObstacles: current_lane not set in blackboard")
		return FAILURE

	var lanes_x: Array[float] = ai.lanes_x
	if lanes_x.is_empty():
		push_error("AnalyzeObstacles: ai.lanes_x is empty")
		return FAILURE
	if not (current_lane >= 0 and current_lane < lanes_x.size()):
		push_error("AnalyzeObstacles: current_lane index out of bounds: %d" % current_lane)
		return FAILURE

	var raw_obstacles: Array = blackboard.get_var(obstacle_data_var_name, [])
	var obstacles_by_lane: Dictionary = _preprocess_obstacles_by_lane(raw_obstacles, lanes_x.size())

	var lane_safety_scores: Array[float] = []
	for i in range(lanes_x.size()):
		lane_safety_scores.append(_calculate_lane_safety_score(obstacles_by_lane[i], ai))

	var current_lane_obstacles_sorted: Array = obstacles_by_lane[current_lane]
	var closest_obstacle = _get_closest_obstacle_from_sorted_list(current_lane_obstacles_sorted)
	var current_lane_state: int = LaneState.CLEAR

	#  Always update nearest_object_var_name with the true closest obstacle
	if closest_obstacle:
		blackboard.set_var(nearest_object_var_name, closest_obstacle)
	else:
		blackboard.set_var(nearest_object_var_name, null)

	if closest_obstacle:
		if not is_instance_valid(closest_obstacle["node"]):
			push_warning("AnalyzeObstacles: Closest obstacle node is invalid.")
			current_lane_state = LaneState.BLOCKED
		else:
			if ai.using_stairs and not ai.is_on_upper_level:
				blackboard.set_var(required_action_var_name, "UseStairs")
				blackboard.set_var(target_lane_var_name, current_lane)
				return SUCCESS

			var node = closest_obstacle["node"]
			var obs_distance: float = closest_obstacle["distance"]

			if node is Gate:
				current_lane_state = LaneState.JUMP
			elif node is Stairs:
				var stairs_z_ref: float = closest_obstacle["position"].z
				var train_after_stairs: bool = _is_train_ahead_on_lane(current_lane_obstacles_sorted, stairs_z_ref)
				var any_obstacle_after_stairs: bool = _is_any_obstacle_ahead_on_lane(current_lane_obstacles_sorted, stairs_z_ref)
				if train_after_stairs or not any_obstacle_after_stairs:
					current_lane_state = LaneState.STAIRS
				else:
					current_lane_state = LaneState.BLOCKED
				if current_lane_state == LaneState.BLOCKED and obs_distance >= danger_threshold:
					current_lane_state = LaneState.CLEAR
			elif node is Train and not ai.is_on_upper_level:
				current_lane_state = LaneState.BLOCKED
			#  Immediate block for any very close obstacle
			elif obs_distance < immediate_block_threshold:
				current_lane_state = LaneState.BLOCKED
			elif obs_distance < danger_threshold:
				current_lane_state = LaneState.BLOCKED

	var action: String = "None"
	var target_lane: int = current_lane

	match current_lane_state:
		LaneState.JUMP:
			action = "Jump"
		LaneState.STAIRS:
			action = "UseStairs"
		LaneState.BLOCKED:
			action = "None" # Will attempt lane change if possible

	# Lane Changing Logic
	var best_other_lane: int = -1
	var max_other_safety: float = -INF
	for i in range(lanes_x.size()):
		if i == current_lane:
			continue
		if lane_safety_scores[i] > max_other_safety:
			max_other_safety = lane_safety_scores[i]
			best_other_lane = i

	var consider_lane_change: bool = false
	if best_other_lane != -1:
		var current_lane_safety: float = lane_safety_scores[current_lane]
		if current_lane_state == LaneState.BLOCKED:
			if max_other_safety > current_lane_safety:
				consider_lane_change = true
		else: # Not blocked, change only if significantly safer
			if max_other_safety > current_lane_safety + lane_change_safety_bias:
				consider_lane_change = true

	var is_changing_lanes: bool = blackboard.get_var("is_changing_lanes", false)
	if (
		consider_lane_change
		and max_other_safety > danger_threshold # Target lane must be generally safe
		and not is_changing_lanes
		and _is_switch_to_lane_immediately_safe(best_other_lane, obstacles_by_lane, ai)
	):
		action = "ChangeLane"
		target_lane = best_other_lane

	# Set blackboard variables
	blackboard.set_var(required_action_var_name, action)
	if action == "ChangeLane":
		blackboard.set_var(target_lane_var_name, target_lane)
	elif action == "UseStairs": # Ensure target lane is current for stairs
		blackboard.set_var(target_lane_var_name, current_lane)
	return SUCCESS
