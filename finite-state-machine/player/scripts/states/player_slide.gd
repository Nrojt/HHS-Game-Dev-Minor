extends PlayerState
class_name PlayerSlide

@export var SLIDE_SPEED: float = 500.0
@export var DECELERATION: float = 1000.0
@export var MIN_SLIDE_SPEED: float = 100.0


func enter(_previous_state: StateEnums.PlayerStateType) -> void:
	player.velocity.x = SLIDE_SPEED * sign(player.velocity.x)


func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("slide"):
		transition.emit(StateEnums.PlayerStateType.IDLE)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, DECELERATION * delta)
		if abs(player.velocity.x) < MIN_SLIDE_SPEED:
			transition.emit(StateEnums.PlayerStateType.WALK)
