extends PlayerState
class_name PlayerRun

@export var MOVE_SPEED: float = 150.0


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	if direction:
		PLAYER.velocity.x = direction * MOVE_SPEED
	else:
		PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, MOVE_SPEED)
