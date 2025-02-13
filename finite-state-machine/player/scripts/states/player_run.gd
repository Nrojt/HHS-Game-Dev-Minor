extends PlayerState
class_name PlayerRun

func update(_delta: float) -> void:
	# going into the slide
	if (Input.is_action_just_pressed("slide")):
		transition.emit(StateEnums.PlayerStateType.SLIDE)


func physics_update(delta):
	super(delta)

	if player.is_on_floor():
		if player.velocity.x == 0:
			transition.emit(StateEnums.PlayerStateType.IDLE)
		if Input.is_action_just_pressed("jump"):
			transition.emit(StateEnums.PlayerStateType.JUMP)
		if Input.is_action_just_pressed("slide"):
			transition.emit(StateEnums.PlayerStateType.SLIDE)
	elif not player.is_on_floor():
		transition.emit(StateEnums.PlayerStateType.FALL)
