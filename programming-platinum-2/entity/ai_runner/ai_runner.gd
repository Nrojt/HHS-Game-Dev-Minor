extends CharacterBody3D

enum State { RUN, LANE_CHANGE, JUMPING, SLIDING }

# Configuration
@export var lanes_x := [-2.5, 0.0, 2.5]
@export var lane_switch_speed := 8.0
@export var jump_velocity := 12.0
@export var slide_duration := 0.5
@export var lookahead_distance := 20.0
@export var jump_clearance_height := 1.5

# State
var current_lane: int = 1
var target_lane: int = 1
var state: State = State.RUN
var slide_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_state_transitions(delta)
	move_and_slide()

func handle_movement(delta: float) -> void:
	# Start with current velocity to maintain momentum
	var movement: Vector3 = velocity

	match state:
		State.JUMPING:
			movement.y = jump_velocity
			state = State.RUN # Should likely happen when grounded, not immediately
		State.SLIDING:
			handle_slide(delta)
		State.RUN:
			pass
		State.LANE_CHANGE:
			pass

	# Apply gravity only if not on floor or jumping
	if not is_on_floor():
		movement.y -= gravity * delta
	else:
		# Reset vertical velocity only when grounded and not initiating a jump
		if state != State.JUMPING:
			movement.y = 0.0

	velocity = movement

	if is_on_floor() and state == State.JUMPING:
		state = State.RUN


func handle_state_transitions(delta: float) -> void:
	match state:
		State.RUN:
			evaluate_obstacles()
		State.LANE_CHANGE:
			update_lane_position(delta)
		State.SLIDING:
			pass # Slide logic is handled in handle_movement/handle_slide
		State.JUMPING:
			# Transition back to RUN when grounded
			if is_on_floor():
				state = State.RUN


func evaluate_obstacles() -> void:
	var obstacles := scan_for_obstacles()

	if has_immediate_obstacle(obstacles):
		# Access the 'nodes' array within the 'obstacles' dictionary
		respond_to_obstacle(obstacles.nodes[current_lane])
	elif state == State.RUN: # Only consider lane change if currently running
		consider_lane_change(obstacles)


func scan_for_obstacles() -> Dictionary:
	# Initialize with default values
	var obstacle_data := {
		"nodes": [null, null, null],
		"distances": [INF, INF, INF]
	}

	# Ensure the group exists and has nodes
	if not get_tree().has_group("Obstacles"):
		printerr("Obstacle group 'Obstacles' not found.")
		return obstacle_data

	for obstacle in get_tree().get_nodes_in_group("Obstacles"):
		# Basic type check and ensure obstacle has necessary properties/methods
		if not obstacle is Draggable:
			printerr("Obstacle node is not draggable: ", obstacle)
			continue

		# Get obstacle's Z position relative to runner
		var distance_z: float = obstacle.global_position.z - global_position.z

		# Check if obstacle is within lookahead range (only ahead)
		if distance_z > 0.0 and distance_z < lookahead_distance:
			var lane: int = obstacle.get_meta("lane_index", -1) # Get lane index safely

			# Validate lane index
			if lane >= 0 and lane < lanes_x.size():
				# Check if this obstacle is closer than the one already found for this lane
				if distance_z < obstacle_data.distances[lane]:
					obstacle_data.distances[lane] = distance_z
					obstacle_data.nodes[lane] = obstacle
			else:
				printerr("Obstacle has invalid lane_index: ", lane, " on node: ", obstacle)

	return obstacle_data


func has_immediate_obstacle(obstacle_data: Dictionary) -> bool:
	# Check if there's a node registered for the current lane
	return obstacle_data.nodes[current_lane] != null


func respond_to_obstacle(obstacle: Node3D) -> void:
	# Ensure obstacle is valid before accessing properties
	if not is_instance_valid(obstacle) or not obstacle.has_meta("height"):
		printerr("Invalid obstacle passed to respond_to_obstacle.")
		return

	# Assuming 'height' is stored as metadata or a property
	var obstacle_height: float = obstacle.get_meta("height", 1.0) # Default height if meta not found
	var obstacle_top: float = obstacle.global_position.y + obstacle_height * 0.5

	# Check relative height for jump clearance
	if obstacle_top - global_position.y < jump_clearance_height:
		perform_jump()
	else:
		initiate_slide()


func consider_lane_change(obstacle_data: Dictionary) -> void:
	var available_lanes: Array[int] = []

	for lane_index in range(lanes_x.size()):
		# Check if the lane is different and has no obstacle node registered
		if lane_index != current_lane and obstacle_data.nodes[lane_index] == null:
			available_lanes.append(lane_index)

	if available_lanes.size() > 0:
		change_to_lane(available_lanes.pick_random())


func change_to_lane(new_lane: int) -> void:
	if state == State.RUN: # Only allow lane change from RUN state
		target_lane = new_lane
		state = State.LANE_CHANGE


func update_lane_position(delta: float) -> void:
	var target_x: float = lanes_x[target_lane]
	var current_x: float = global_transform.origin.x
	var remaining_distance: float = target_x - current_x

	# Avoid division by zero or tiny movements if already close
	if abs(remaining_distance) < 0.01:
		finalize_lane_change(target_x)
		return

	var movement_step: float = sign(remaining_distance) * lane_switch_speed * delta

	# Clamp movement step to not overshoot the target
	if abs(movement_step) >= abs(remaining_distance):
		movement_step = remaining_distance
		finalize_lane_change(target_x) # Finalize if this step reaches the target
	else:
		translate(Vector3(movement_step, 0, 0))


func finalize_lane_change(final_x: float) -> void:
	var new_transform: Transform3D = global_transform
	new_transform.origin.x = final_x
	global_transform = new_transform
	current_lane = target_lane
	state = State.RUN


func perform_jump() -> void:
	# Only jump if on the floor and in RUN state
	if is_on_floor() and state == State.RUN:
		state = State.JUMPING
		# The actual velocity application happens in handle_movement


func initiate_slide() -> void:
	# Only slide if on the floor and in RUN state
	if is_on_floor() and state == State.RUN:
		state = State.SLIDING
		slide_timer = slide_duration
		# TODO: Implement collision shape adjustment here
		print("Start Slide") # Placeholder


func handle_slide(delta: float) -> void:
	slide_timer -= delta
	if slide_timer <= 0.0:
		end_slide()


func end_slide() -> void:
	# Ensure we are actually sliding before ending it
	if state == State.SLIDING:
		state = State.RUN
		# TODO: Restore collision shape here
		print("End Slide") # Placeholder
