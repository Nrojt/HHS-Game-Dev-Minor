extends PlayerState
class_name PlayerFall

func update(_delta: float) -> void:
	# switch to dash
	if (Input.is_action_just_pressed("dash")):
		transition.emit(StateEnums.PlayerStateType.DASH)


func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * delta

	if player.is_on_floor():
		if player.velocity.x != 0:
			transition.emit(StateEnums.PlayerStateType.IDLE)
		else:
			transition.emit(StateEnums.PlayerStateType.WALK)

	# Get the input direction and handle the movement/deceleration.
	super(delta)
