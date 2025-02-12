extends PlayerState
class_name PlayerRun

@export var MOVE_SPEED: float = 150.0


func physics_update(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * MOVE_SPEED * delta
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, MOVE_SPEED * delta)
