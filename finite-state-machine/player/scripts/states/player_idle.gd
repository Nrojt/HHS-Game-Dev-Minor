extends PlayerState
class_name PlayerIdle

func enter(_previous_state: StateEnums.PlayerStateType) -> void:
	player.velocity.x = 0


func physics_update(_delta: float) -> void:
	if !player.is_on_floor():
		transition.emit(StateEnums.PlayerStateType.FALL)

	if Input.is_action_just_pressed("jump") && player.is_on_floor():
		transition.emit(StateEnums.PlayerStateType.JUMP)

	if(Input.get_action_strength("left") != 0 || Input.get_action_strength("right") != 0):
		transition.emit(StateEnums.PlayerStateType.WALK)
