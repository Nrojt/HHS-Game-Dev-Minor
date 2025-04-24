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

func handle_movement(delta: float) -> void:
	var movement := Vector3.ZERO

	match state:
		State.JUMPING:
			movement.y = jump_velocity
			state = State.RUN
		State.SLIDING:
			handle_slide(delta)

		State.RUN:
			pass
		State.LANE_CHANGE:
			pass
	movement.y -= gravity * delta
	velocity = movement
	print(gravity)
	move_and_slide()

func handle_state_transitions(delta: float) -> void:
	match state:
		State.RUN:
			evaluate_obstacles()
		State.LANE_CHANGE:
			update_lane_position(delta)

		State.SLIDING:
			pass
		State.JUMPING:
			pass
func evaluate_obstacles() -> void:
	var obstacles := scan_for_obstacles()

	if has_immediate_obstacle(obstacles):
		respond_to_obstacle(obstacles[current_lane])
	else:
		consider_lane_change(obstacles)

func scan_for_obstacles() -> Dictionary:
	var obstacle_data := {
		nodes = [null, null, null],
		distances = [INF, INF, INF]
	}

	for obstacle in get_tree().get_nodes_in_group("Obstacles"):
		# Get obstacle's Z position relative to runner
		var distance_z = obstacle.global_position.z - global_position.z
		if distance_z > -lookahead_distance and distance_z < lookahead_distance:
			var lane: int = obstacle.lane_index
			if abs(distance_z) < obstacle_data.distances[lane]:
				obstacle_data.distances[lane] = abs(distance_z)
				obstacle_data.nodes[lane] = obstacle

	return obstacle_data

func has_immediate_obstacle(obstacle_data: Dictionary) -> bool:
	return obstacle_data.nodes[current_lane] != null

func respond_to_obstacle(obstacle: Node3D) -> void:
	var obstacle_top: float = obstacle.global_position.y + obstacle.height * 0.5
	if obstacle_top < jump_clearance_height:
		perform_jump()
	else:
		initiate_slide()

func consider_lane_change(obstacle_data: Dictionary) -> void:
	var available_lanes: Array[int] = []
	
	for lane_index in range(lanes_x.size()):
		if lane_index != current_lane && obstacle_data.nodes[lane_index] == null:
			available_lanes.append(lane_index)
	
	if available_lanes.size() > 0:
		change_to_lane(available_lanes.pick_random())

func change_to_lane(new_lane: int) -> void:
	target_lane = new_lane
	state = State.LANE_CHANGE

func update_lane_position(delta: float) -> void:
	var target_x: float = lanes_x[target_lane]
	var current_x: float = global_transform.origin.x
	var remaining_distance: float = target_x - current_x
	
	var movement_step: float = sign(remaining_distance) * lane_switch_speed * delta
	if abs(movement_step) > abs(remaining_distance):
		movement_step = remaining_distance
		
	translate(Vector3(movement_step, 0, 0))
	
	if abs(remaining_distance) < 0.05:
		finalize_lane_change(target_x)

func finalize_lane_change(final_x: float) -> void:
	var new_transform: Transform3D = global_transform
	new_transform.origin.x = final_x
	global_transform = new_transform
	current_lane = target_lane
	state = State.RUN

func perform_jump() -> void:
	if state == State.RUN:
		state = State.JUMPING

func initiate_slide() -> void:
	if state == State.RUN:
		state = State.SLIDING
		slide_timer = slide_duration
		# TODO: Implement collision shape adjustment here

func handle_slide(delta: float) -> void:
	slide_timer -= delta
	if slide_timer <= 0.0:
		end_slide()

func end_slide() -> void:
	state = State.RUN
	# TODO: Restore collision shape here
