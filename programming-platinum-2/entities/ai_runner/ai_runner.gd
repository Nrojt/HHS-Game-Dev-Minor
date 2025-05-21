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
@export_group("limbo")
@export var bt_player: BTPlayer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var initial_z_pos : float
var is_on_upper_level := false
var using_stairs := false

var suppress_z_correction := false

@onready var running_sound_effect : AudioStreamPlayer3D = $RunningSoundEffect

func _ready() -> void:
	initial_z_pos = global_position.z
	# Initial state variables for the blackboard
	bt_player.blackboard.set_var("current_lane", 1) # Start in middle lane
	bt_player.blackboard.set_var("target_lane", 1) # Initial target for conditions
	bt_player.blackboard.set_var("is_jumping", false)
	GameManager.game_started.connect(
		func():
			position = Vector3(0,2,0)
			velocity = Vector3.ZERO
	)

func _physics_process(delta: float) -> void:
	if !GameManager.game_active:
		if bt_player.is_processing():
			bt_player.set_process(false)
		return
	else:
		if !bt_player.is_processing():
			bt_player.set_process(true)
	if global_position.z >= (initial_z_pos + z_death_difference):
		GameManager.game_active = false
		global_position = Vector3(0,2,0)

	# Gravity always applies
	var is_jumping = bt_player.blackboard.get_var("is_jumping", false)
	if !is_on_floor():
		running_sound_effect.stop()
		is_on_upper_level = false
		velocity.y -= gravity * delta
		if !is_jumping:
			velocity.z = 0
	else:
		if !running_sound_effect.playing:
			running_sound_effect.play()

	# Only set velocity.z for lane switching if NOT jumping and not suppressed
	
	if is_on_floor() and !is_jumping and !suppress_z_correction:
		# Only move in Z to return to z=0 (if needed), but not during jump
		var direction: float = 0.0 - global_position.z
		if abs(direction) > 0.01:
			velocity.z = sign(direction) * lane_switch_speed
		else:
			velocity.z = 0.0

	move_and_slide()

	# Clamp X position to stay within lane boundaries + wiggle_room
	if lanes_x.size() > 0:
		var min_x_limit = lanes_x[0] - wiggle_room
		var max_x_limit = lanes_x[lanes_x.size() - 1] + wiggle_room

		if global_position.x < min_x_limit:
			global_position.x = min_x_limit
		elif global_position.x > max_x_limit:
			global_position.x = max_x_limit
	# upping height if it somehow falls off the map
	if global_position.y < 1.35: global_position.y = 1.4
