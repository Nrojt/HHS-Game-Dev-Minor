extends CameraState

func enter() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# TODO: lock the camera down towards the ground
	# camera_transformer.rotation.x = -PI/4

func update(delta) -> void:

	var direction := Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("forward") - Input.get_action_strength("backward"),
		0
	)

	if Input.is_action_just_pressed("spawn_droppable_button"):
		# spawn droppable in front of camera
		var spawn_location := camera_transformer.global_position - camera_transformer.global_transform.basis.z * 2
		SignalManager.spawn_droppable.emit(spawn_location)
	
	camera_transformer.translate(direction * _velocity * delta)

	if Input.is_action_just_pressed("switch_camera_state"):
		transition.emit(CreatedEnums.CameraStateType.FREECAM)

		
