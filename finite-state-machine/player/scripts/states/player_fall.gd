extends PlayerState
class_name PlayerFall

@export var MOVE_SPEED: float = 1000.0


func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * delta

	if player.is_on_floor():
		if player.velocity.x != 0:
			transition.emit(StateEnums.PlayerStateType.IDLE)
		else:
			transition.emit(StateEnums.PlayerStateType.WALK)

	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	print(direction)
	if direction:
		player.velocity.x = direction * MOVE_SPEED * delta
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, MOVE_SPEED * delta)

	player.move_and_slide()