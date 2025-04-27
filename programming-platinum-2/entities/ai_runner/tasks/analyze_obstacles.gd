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

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE

	var current_lane = ai.bt_player.blackboard.get_var("current_lane", -1)
	if current_lane == -1:
		return FAILURE

	var lanes_x: Array[float] = ai.lanes_x
	var obstacles: Array = blackboard.get_var(obstacle_data_var_name, [])
	var ai_y: float = ai.global_position.y

	# Calculate safety score for each lane
	var safety: Array[Variant] = []
	for i in lanes_x.size():
		safety.append(_get_lane_safety(i, obstacles, ai_y))

	# Find the closest obstacle in the current lane
	var closest = _get_closest_obstacle_in_lane(current_lane, obstacles)

	# Determine the state of the current lane
	var state: int = LaneState.CLEAR
	if closest:
		# Check for if the ai is still climbing stairs
		if ai.using_stairs and not ai.is_on_upper_level:
			blackboard.set_var(required_action_var_name, "UseStairs")
			blackboard.set_var(target_lane_var_name, current_lane)
			return SUCCESS
		if closest.node is Gate:
			state = LaneState.JUMP
		elif closest.node is Stairs:
			var stairs_z = closest["position"].z
			var found_train: bool = _is_train_ahead(obstacles, current_lane, stairs_z)
			var found_any: bool = _is_any_obstacle_ahead(obstacles, current_lane, stairs_z)
			state = LaneState.STAIRS if found_train or not found_any else LaneState.BLOCKED
			if closest["distance"] >= danger_threshold and state == LaneState.BLOCKED:
				state = LaneState.CLEAR
		elif closest.node is Train and !ai.is_on_upper_level: 
			state = LaneState.BLOCKED
		elif closest["distance"] < danger_threshold:
			state = LaneState.BLOCKED

	# Decide what action to take
	var action: String = "None"
	var target_lane = current_lane

	if state == LaneState.JUMP:
		action = "Jump"
		blackboard.set_var(nearest_object_var_name, closest)
	elif state == LaneState.STAIRS:
		action = "UseStairs"
	elif state == LaneState.BLOCKED:
		action = "None"

	# Lane change logic: switch if another lane is significantly safer
	for i in lanes_x.size():
		if i == current_lane:
			continue
		var bias: float = lane_change_safety_bias if state != LaneState.BLOCKED else 0.0
		if safety[i] > safety[current_lane] + bias:
			action = "ChangeLane"
			target_lane = i
			break

	# If blocked, try to escape to any lane that's not immediately blocked
	if state == LaneState.BLOCKED and action != "ChangeLane":
		for i in lanes_x.size():
			if i != current_lane and safety[i] > danger_threshold:
				action = "ChangeLane"
				target_lane = i
				break

	# Set the action and target lane in the blackboard
	blackboard.set_var(required_action_var_name, action)
	if action in ["ChangeLane", "UseStairs"]:
		blackboard.set_var(target_lane_var_name, target_lane)

	print("Analyze: lane %d, state %s, safety %s, action %s, target %d" % [
	current_lane, LaneState.keys()[state], safety, action, target_lane
	])

	return SUCCESS

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
		if o["lane"] == lane and o["position"].z > z and o["position"].z - z < 5.0 and o.node is Train:
			return true
	return false

# Returns true if there is any obstacle ahead of position z in the given lane.
func _is_any_obstacle_ahead(obstacles: Array, lane: int, z: float) -> bool:
	for o in obstacles:
		if o["lane"] == lane and o["position"].z > z and o["position"].z - z < 5.0:
			return true
	return false

# Returns the safety score for a lane: the distance to the first dangerous obstacle, or scan_distance if clear.
func _get_lane_safety(lane: int, obstacles: Array, ai_y: float) -> float:
	var obs: Array = _get_lane_obstacles(lane, obstacles)
	_sort_obstacles_by_distance(obs)
	for i in range(min(lookahead_steps, obs.size())):
		var o = obs[i]
		if o["distance"] < danger_threshold or (o.node is Train and ai_y < 2.0):
			return o["distance"]
	return scan_distance

# Returns the closest obstacle in a lane, or null if none.
func _get_closest_obstacle_in_lane(lane: int, obstacles: Array) -> Variant:
	var obs_in_lane: Array = _get_lane_obstacles(lane, obstacles)
	_sort_obstacles_by_distance(obs_in_lane)
	return obs_in_lane[0] if obs_in_lane.size() > 0 else null
