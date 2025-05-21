class_name ExecuteJump
extends BTAction

var _jump_horizontal_speed: float = 0.0

# Note: reversed z axis, so negative z is forward and positive z is backwards in this project

func _enter() -> void:
	_jump_horizontal_speed = GameManager.movement_speed
	
func _exit() -> void:
	# Reset jump state
	var ai: AiRunner = agent as AiRunner
	if ai:
		ai.suppress_z_correction = false # Allow Z-axis correction again
		blackboard.set_var("is_jumping", false) # Ensure state is clean
		ai.velocity.z = 0.0 # Stop forward movement applied during jump


func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		blackboard.set_var("is_jumping", false)
		return FAILURE

	var is_currently_jumping: bool = blackboard.get_var("is_jumping", false)

	if is_currently_jumping:
		# Handle ongoing jump
		if ai.is_on_floor():
			# Landed, Jump sequence complete
			ai.velocity.z = 0.0 # Stop forward movement applied during jump
			ai.suppress_z_correction = false # Allow Z-axis correction again
			blackboard.set_var("is_jumping", false)
			return SUCCESS # Jump finished successfully
		else:
			# Still in the air: Continue jump
			ai.suppress_z_correction = true # Ensure suppression mid-air
			return RUNNING # Jump is still in progress
	else:
		# Initiate a new jump
		# This block should only be reached if CanInitiateJump just succeeded.
		# As a final safety, double-check if on floor before applying jump velocity.
		if not ai.is_on_floor():
			# This is unexpected if CanInitiateJump ran correctly.
			push_warning(
				"ExecuteJump: Tried to initiate jump but not on floor."
			)
			ai.suppress_z_correction = false
			blackboard.set_var("is_jumping", false) # Ensure state is clean
			return FAILURE

		ai.velocity.y = ai.jump_velocity
		ai.velocity.z = -abs(_jump_horizontal_speed) # Apply forward speed

		blackboard.set_var("is_jumping", true)
		ai.suppress_z_correction = true # Suppress Z-axis correction during the jump
		return RUNNING # Jump has started and is in progress
