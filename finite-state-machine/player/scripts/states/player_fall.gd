extends PlayerState
class_name PlayerFall

var dashed : bool = false

func enter(previous_state: StateEnums.PlayerStateType = StateEnums.PlayerStateType.UNDEFINED) -> void:
	if previous_state == StateEnums.PlayerStateType.DASH:
		dashed = true
	else:
		dashed = false
	

func update(_delta: float) -> void:
	# switch to dash
	if (Input.is_action_just_pressed("dash") && !dashed):
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
