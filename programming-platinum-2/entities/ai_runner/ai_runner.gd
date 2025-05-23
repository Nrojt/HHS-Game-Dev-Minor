class_name AiRunner
extends CharacterBody3D

# AI Configuration
@export_group("ai variables")
@export var lanes_x : Array[float]= [-2.5, 0.0, 2.5] # x positions of the lanes
@export var lane_switch_speed := 10.0
@export var jump_velocity := 12.0
@export var lookahead_distance := 25.0
@export var jump_clearance_height := 1.5
@export var z_death_difference := 10.0
@export var wiggle_room := 0.4 # Max deviation from the boundary of the outermost lanes
@export var max_z_velocity := 15.0 # Maximum speed in the Z direction
@export_group("limbo")
@export var bt_player: BTPlayer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var initial_z_pos : float
var is_on_upper_level := false
var using_stairs := false

var suppress_z_correction := false

@onready var running_sound_effect : AudioStreamPlayer3D = $RunningSoundEffect

func _ready() -> void:
	bt_player.active = false
	running_sound_effect.stop()
	initial_z_pos = global_position.z
	# Initial state variables for the blackboard
	bt_player.blackboard.set_var("current_lane", 1) # Start in middle lane
	bt_player.blackboard.set_var("target_lane", 1) # Initial target for conditions
	bt_player.blackboard.set_var("is_jumping", false)
	GameManager.game_started.connect(
		func():
			position = Vector3(0,2,0)
			velocity = Vector3.ZERO
			initial_z_pos = global_position.z # Reset initial_z_pos on game restart
			bt_player.active = true
			running_sound_effect.play()
	)

func _physics_process(delta: float) -> void:
	if !GameManager.game_active || !is_inside_tree():
		if bt_player.is_processing():
			bt_player.set_process(false)
		return
	else:
		if !bt_player.is_processing():
			bt_player.set_process(true)

	if global_position.z >= (initial_z_pos + z_death_difference):
		GameManager.game_active = false
		global_position = Vector3(0,2,0) # Reset position

	# Gravity always applies
	var is_jumping = bt_player.blackboard.get_var("is_jumping", false)
	if !is_on_floor():
		running_sound_effect.stop()
		is_on_upper_level = false
		using_stairs = false
		velocity.y -= gravity * delta
		if !is_jumping: # If falling without initiating a jump
			velocity.z = 0.0 # Stop Z movement
	else:
		if !running_sound_effect.playing:
			running_sound_effect.play()

	# Z-axis correction to return to z=0 when on floor, not jumping, and not suppressed
	if is_on_floor() and !is_jumping and !suppress_z_correction:
		var z_target: float = 0.0
		var z_diff: float = z_target - global_position.z
		var z_correction_threshold: float = 0.05  # Increased threshold
	
		if abs(z_diff) > z_correction_threshold:
			# Use proportional correction speed instead of fixed speed
			var correction_speed: float = min(abs(z_diff) * 8.0, lane_switch_speed * 0.5)
			velocity.z = sign(z_diff) * correction_speed
		else:
			velocity.z = 0.0
			global_position.z = z_target
	
	# Clamp Z velocity
	velocity.z = clamp(velocity.z, -max_z_velocity, max_z_velocity)
	# Clamp Z location
	global_position.z = clamp(global_position.z, -z_death_difference, initial_z_pos + z_death_difference)
	
	# Clamp X position to stay within lane boundaries + wiggle_room
	if lanes_x.size() > 0:
		var min_x_limit: float = lanes_x[0] - wiggle_room
		var max_x_limit: float = lanes_x[lanes_x.size() - 1] + wiggle_room

		global_position.x = clamp(global_position.x, min_x_limit, max_x_limit)

	# upping height if it somehow falls off the map
	if global_position.y < 1.35: global_position.y = 1.4

	# Add velocity damping for very small movements to reduce jitter
	var velocity_deadzone: float = 0.1
	if abs(velocity.x) < velocity_deadzone:
		velocity.x = 0.0
	if abs(velocity.z) < velocity_deadzone and is_on_floor() and !is_jumping:
		velocity.z = 0.0
		
	
	move_and_slide()
