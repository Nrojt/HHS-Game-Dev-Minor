class_name PerformJump
extends BTAction

@export var nearest_object_var_name: StringName = "nearest_object_distance"
@export var nearest_object_jump_start_distance: float = 3.0

var _jump_horizontal_speed: float = 0.0

# Note: reversed z axis, so negative z is forward and positive z is backwards in this project

func _setup() -> void:
	# Use the world/obstacle movement speed (should be positive)
	_jump_horizontal_speed = GameManager.movement_speed

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		blackboard.set_var("is_jumping", false)
		return FAILURE

	var is_jumping = blackboard.get_var("is_jumping", false)
	var closest_obstacle_data = blackboard.get_var(nearest_object_var_name, null)

	if not is_jumping:
		if ai.is_on_upper_level:
			# Already on upper level, no jump needed
			blackboard.set_var("is_jumping", false)
			return FAILURE
		# if ai is in the air, don't jump and fail
		if not ai.is_on_floor():
			blackboard.set_var("is_jumping", false)
			return FAILURE
			
		ai.suppress_z_correction = false  # Not jumping, allow correction
		# Only try to jump if not already jumping
		if (
			closest_obstacle_data == null
			or not closest_obstacle_data.has("distance")
		):
			blackboard.set_var("is_jumping", false)
			return FAILURE

		var z_dist_to_obstacle: float = closest_obstacle_data["distance"]

		# Start jump if close enough and on floor
		if z_dist_to_obstacle <= nearest_object_jump_start_distance and ai.is_on_floor():
			ai.velocity.y = ai.jump_velocity
			# Move forward (negative Z) to match world/obstacle movement
			ai.velocity.z = -abs(_jump_horizontal_speed) # Set forward speed ONCE
			blackboard.set_var("is_jumping", true)
			ai.suppress_z_correction = true # Suppress correction during jump
			return RUNNING
		else:
			blackboard.set_var("is_jumping", false)
			return FAILURE

	# If already jumping, do NOT keep setting velocity.z!
	if not ai.is_on_floor():
		ai.suppress_z_correction = true
		return RUNNING
	else:
		# Landed, jump is complete
		blackboard.set_var("is_jumping", false)
		ai.velocity.z = 0.0
		ai.suppress_z_correction = false  # Allow correction again
		return SUCCESS
