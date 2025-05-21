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
@export var lane_change_safety_bias: float = 1.5
# Threshold for checking immediate obstacles in the target lane for a switch
@export var immediate_side_collision_threshold: float = 2.0

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
			and o["position"].z - z < unit_safety_check_size
			and o["node"] is Train
		):
			return true
	return false


# Returns true if there is any obstacle ahead of position z in the given lane.
func _is_any_obstacle_ahead(obstacles: Array, lane: int, z: float) -> bool:
	for o in obstacles:
		if (
			o["lane"] == lane
			and o["position"].z > z
			and o["position"].z - z < unit_safety_check_size
		):
			return true
	return false


# Returns the safety score for a lane: distance to the first ground-level Train,
# or distance to the first obstacle < danger_threshold, or scan_distance if clear.
# Ground-level trains are prioritized as the most significant danger.
func _get_lane_safety(lane: int, obstacles: Array, ai: AiRunner) -> float:
	var obs_in_lane: Array = _get_lane_obstacles(lane, obstacles)
	_sort_obstacles_by_distance(obs_in_lane)

	# Check for ground-level trains within scan_distance
	for o in obs_in_lane:
		if not is_instance_valid(o["node"]):
			push_warning(
				"AnalyzeObstacles: Invalid obstacle node in train check for lane %d."
				% lane
			)
			return 0.0 # Max danger (effectively distance 0)

		if o["distance"] > scan_distance:
			break # Further obstacles in this sorted list are also > scan_distance

		# Gates don't affect safety, they can be jumped over
		if o["node"] is Gate:
			continue  # Skip gates in safety calculation

		if o["node"] is Train and not ai.is_on_upper_level:
			return o["distance"] # Ground-level train found, its distance is the safety

	# If no ground-level train determined safety, check other obstacles
	for i in range(min(lookahead_steps, obs_in_lane.size())):
		var o = obs_in_lane[i]

		if not is_instance_valid(o["node"]):
			push_warning(
				"AnalyzeObstacles: Invalid obstacle node in general check for lane %d."
				% lane
			)
			return 0.0  # Max danger

		# If this obstacle (within lookahead_steps) is beyond scan_distance, and no prior train/dangerous obstacle set the score, lane is clear up to scan_distance.
		if o["distance"] > scan_distance:
			return scan_distance

		# Skip gates when evaluating danger threshold
		if o["node"] is Gate:
			continue

		# Check if it's dangerous due to proximity (closer than danger_threshold).
		if o["distance"] < danger_threshold:
			return o["distance"]  # Dangerous due to proximity.

	# If loop completes: No specific danger found according to the rules above.
	return scan_distance



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
	if lanes_x.is_empty():
		push_error("AnalyzeObstacles: ai.lanes_x is empty")
		return FAILURE
	if current_lane < 0 or current_lane >= lanes_x.size():
		push_error(
			"AnalyzeObstacles: current_lane index out of bounds: %d" % current_lane
		)
		return FAILURE

	var obstacles: Array = blackboard.get_var(obstacle_data_var_name, [])

	# Calculate the safety of each lane
	var safety: Array[Variant] = [] # Will store floats
	for i in lanes_x.size():
		safety.append(_get_lane_safety(i, obstacles, ai))

	# Checking the closest obstacle in the current lane
	var closest = _get_closest_obstacle_in_lane(current_lane, obstacles)
	var state: int = LaneState.CLEAR
	if closest:
		if not is_instance_valid(closest["node"]):
			push_warning("AnalyzeObstacles: Closest obstacle node is invalid.")
			state = LaneState.BLOCKED # Treat as blocked if invalid
		else:
			# Check for if the ai is still climbing stairs
			if ai.using_stairs and not ai.is_on_upper_level:
				blackboard.set_var(required_action_var_name, "UseStairs")
				blackboard.set_var(target_lane_var_name, current_lane)
				return SUCCESS # Continue using stairs

			if closest["node"] is Gate:
				state = LaneState.JUMP
			elif closest["node"] is Stairs:
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
			elif closest["node"] is Train and not ai.is_on_upper_level: # Train on ground level blocks
				state = LaneState.BLOCKED
			elif closest["distance"] < danger_threshold: # Any close obstacle blocks
				state = LaneState.BLOCKED

	# Setting the final action
	var action: String = "None"
	var target_lane = current_lane  # Default target is current lane

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
		# Ensure safety[i] is float before comparison
		var lane_i_safety = safety[i] if typeof(safety[i]) == TYPE_FLOAT else -INF
		if lane_i_safety > max_other_safety:
			max_other_safety = lane_i_safety
			best_other_lane = i

	var should_consider_change: bool = false
	if best_other_lane != -1: # Check if there is an alternative lane
		var current_lane_safety = safety[current_lane] if typeof(safety[current_lane]) == TYPE_FLOAT else -INF
		if state == LaneState.BLOCKED:
			# If blocked, consider changing if any other lane is safer
			if max_other_safety > current_lane_safety:
				should_consider_change = true
		else:
			# If not blocked, consider changing only if the best other lane is significantly safer
			if max_other_safety > current_lane_safety + lane_change_safety_bias:
				should_consider_change = true

	var is_changing_lanes = blackboard.get_var("is_changing_lanes", false)
	# Execute change only if considered AND the target lane is safe enough
	if (
		should_consider_change
		and max_other_safety > danger_threshold # General long-term safety of target lane
		and not is_changing_lanes
	):
		var is_immediate_switch_safe: bool = true # Assume safe initially
		# best_other_lane is valid here because should_consider_change is true
		var closest_obs_in_switch_target = _get_closest_obstacle_in_lane(
			best_other_lane, obstacles
		)

		if closest_obs_in_switch_target:
			if (
				closest_obs_in_switch_target["distance"]
				< immediate_side_collision_threshold
			):
				var obs_node = closest_obs_in_switch_target["node"]
				if is_instance_valid(obs_node):
					# Obstacle is upper if it has "is_upper_level_obstacle" meta set to true
					var obs_is_upper: bool = obs_node.has_meta("is_upper_level_obstacle") and \
									   obs_node.get_meta("is_upper_level_obstacle")

					# Collision if AI and obstacle are on the same level
					if (ai.is_on_upper_level and obs_is_upper) or \
					   (not ai.is_on_upper_level and not obs_is_upper):
						is_immediate_switch_safe = false
				else:
					# Invalid node in target lane, treat as unsafe to switch
					is_immediate_switch_safe = false
		
		if is_immediate_switch_safe:
			action = "ChangeLane"
			target_lane = best_other_lane
		# If not is_immediate_switch_safe, action remains as determined by current lane state.
		# The AI will not attempt a lane change into an immediate obstacle.

	# Blackboard variables
	blackboard.set_var(required_action_var_name, action)

	# Only set target_lane if the action requires it
	if action == "ChangeLane":
		blackboard.set_var(target_lane_var_name, target_lane)
	elif action == "UseStairs": # Also set for UseStairs to ensure it's current lane
		blackboard.set_var(target_lane_var_name, current_lane)
		

	return SUCCESS