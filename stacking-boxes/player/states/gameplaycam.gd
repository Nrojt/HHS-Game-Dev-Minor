extends CameraState

func enter() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_transformer.global_position = camera_transformer_location
	camera_transformer.global_rotation = camera_transformer_initial_rotation

func update(delta) -> void:

	var direction := Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("forward") - Input.get_action_strength("backward"),
		0
	)
		
	if Input.is_action_just_released("spawn_droppable_button"):
		SignalManager.drop_current_droppable.emit()
	
	camera_transformer.translate(direction * _velocity * delta)

	if Input.is_action_just_pressed("switch_camera_state"):
		transition.emit(CreatedEnums.CameraStateType.FREECAM)

	super(delta)
