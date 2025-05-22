class_name ExecuteJump
extends BTAction

var _jump_horizontal_speed: float = 0.0

# Note: reversed z axis, so negative z is forward and positive z is backwards in this project

func _enter() -> void:
	_jump_horizontal_speed = GameManager.movement_speed
	blackboard.set_var("has_been_airborne", false)

func _exit() -> void:
	# Reset jump state
	var ai: AiRunner = agent as AiRunner
	if ai:
		ai.suppress_z_correction = false # Allow Z-axis correction again
		blackboard.set_var("is_jumping", false) # Ensure state is clean
		blackboard.set_var("has_been_airborne", false)
		ai.velocity.z = 0.0 # Stop forward movement applied during jump

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		blackboard.set_var("is_jumping", false)
		blackboard.set_var("has_been_airborne", false)
		return FAILURE

	var is_currently_jumping: bool = blackboard.get_var("is_jumping", false)
	var has_been_airborne: bool = blackboard.get_var("has_been_airborne", false)

	if is_currently_jumping:
		if not ai.is_on_floor():
			# AI is in the air
			blackboard.set_var("has_been_airborne", true)
			ai.suppress_z_correction = true # Ensure suppression mid-air
			return RUNNING # Jump is still in progress
		else:
			# AI is on the floor
			if has_been_airborne:
				# Landed after being airborne, jump complete
				ai.velocity.z = 0.0 # Stop forward movement applied during jump
				ai.suppress_z_correction = false # Allow Z-axis correction again
				blackboard.set_var("is_jumping", false)
				blackboard.set_var("has_been_airborne", false)
				return SUCCESS # Jump finished successfully
			else:
				# Still on floor, but hasn't left yet (first frame)
				return RUNNING
	else:
		# Initiate a new jump
		if not ai.is_on_floor():
			push_warning(
				"ExecuteJump: Tried to initiate jump but not on floor."
			)
			ai.suppress_z_correction = false
			blackboard.set_var("is_jumping", false)
			blackboard.set_var("has_been_airborne", false)
			return FAILURE

		ai.velocity.y = ai.jump_velocity
		ai.velocity.z = -abs(_jump_horizontal_speed) # Apply forward speed

		blackboard.set_var("is_jumping", true)
		blackboard.set_var("has_been_airborne", false)
		ai.suppress_z_correction = true # Suppress Z-axis correction during the jump
		return RUNNING # Jump has started and is in progress
