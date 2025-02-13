extends PlayerState
class_name PlayerJump

@export var JUMP_VELOCITY: float = -1000.0
@export var COYOTE_TIME: float = 0.1

@onready var coyote_timer := $CoyoteTimer


# TODO fix: why can the player sometimes jump twice
# TODO fix jump+falling state

func update(_delta: float) -> void:
	# going into the dash
	if (Input.is_action_just_pressed("dash")):
		transition.emit(StateEnums.PlayerStateType.DASH)

func physics_update(delta):
	# Handle jump
	if Input.is_action_just_pressed("jump") and jump_available:
		jump_available = false
		player.velocity.y = JUMP_VELOCITY * delta

	# Add the gravity.
	if not player.is_on_floor():
		if jump_available and coyote_timer.is_stopped():
			coyote_timer.start(COYOTE_TIME)

	else:
		coyote_timer.stop()
		jump_available = true
		transition.emit(StateEnums.PlayerStateType.FALL)
		
	super(delta)


func exit() -> void:
	coyote_timer.stop()


func _on_coyote_timer_timeout():
	if not player.is_on_floor():
		jump_available = false
		transition.emit(StateEnums.PlayerStateType.FALL)
