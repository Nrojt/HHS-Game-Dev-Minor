extends PlayerState
class_name PlayerJump

@export var JUMP_VELOCITY: float = -420.0


func enter(_previous_state: StateEnums.PlayerStateType = StateEnums.PlayerStateType.UNDEFINED) -> void:
	player.velocity.y += JUMP_VELOCITY


func update(_delta: float) -> void:
	# going into the dash
	if (Input.is_action_just_pressed("dash")):
		transition.emit(StateEnums.PlayerStateType.DASH)


func physics_update(delta):

	# Handle gravity
	player.velocity += player.get_gravity() * delta

	if player.velocity.y >= 0:
		transition.emit(StateEnums.PlayerStateType.FALL)

	# Handle movement
	super(delta)