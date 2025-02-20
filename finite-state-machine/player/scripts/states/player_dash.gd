extends PlayerState
class_name PlayerDash

@export var DASH_SPEED: float = 18000.0
@export var DASH_DURATION: float = 0.4

var dash_time: float = 0.0


func enter(_previous_state: StateEnums.PlayerStateType) -> void:
	# setting the .y velocity to 0
	player.velocity.y = 0

	dash_time = DASH_DURATION


func physics_update(delta: float) -> void:
	dash_time -= delta
	if dash_time <= 0:
		transition.emit(StateEnums.PlayerStateType.FALL)
	else:
		var direction = sign(player.velocity.x)
		# fix: correct ternary operator usage
		if direction == 0:
			direction = -1 if player.animated_sprite.flip_h else 1
		player.velocity.x = DASH_SPEED * direction * delta
