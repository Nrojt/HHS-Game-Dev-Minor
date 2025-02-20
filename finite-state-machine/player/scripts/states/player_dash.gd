extends PlayerState
class_name PlayerDash

@export var DASH_SPEED: float = 1500.0
@export var DASH_DURATION: float = 0.6

var dash_time: float = 0.0


func enter(_previous_state: StateEnums.PlayerStateType = StateEnums.PlayerStateType.UNDEFINED) -> void:
	# setting the .y velocity to 0
	player.velocity.y = 0

	dash_time = DASH_DURATION
	var direction = sign(player.velocity.x)
	player.velocity.x = DASH_SPEED * direction


func physics_update(delta: float) -> void:
	dash_time -= delta
	if dash_time <= 0:
		transition.emit(StateEnums.PlayerStateType.FALL)
	else:
		var direction = sign(player.velocity.x)
		player.velocity.x = DASH_SPEED * direction * delta
