extends CameraState

@export var under_camera_height: float = 5


func enter() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_transformer.global_position = camera_transformer_location
	camera_transformer.global_rotation = camera_transformer_initial_rotation
	SignalManager.update_camera_height.connect(_on_update_camera_height)


func update(delta) -> void:
	if GameManager.current_droppable == null:
		SignalManager.spawn_droppable.emit(get_under_camera_location())
	elif GameManager.current_droppable.is_holding:
		SignalManager.move_current_droppable.emit(get_under_camera_location())

	var direction := Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("forward") - Input.get_action_strength("backward"),
		0
	)

	if Input.is_action_just_pressed("spawn_droppable_button"):
		SignalManager.drop_current_droppable.emit()

	camera_transformer.translate(direction * _velocity * delta)
	camera_transformer.global_position.y = camera_transformer_location.y

	if Input.is_action_just_pressed("switch_camera_state"):
		transition_next.emit()


func _on_update_camera_height(height: float) -> void:
	# updating camera_transformer_location height based on the pile height
	camera_transformer_location.y += height
	print("Camera height updated to: ", camera_transformer_location.y)


func get_under_camera_location() -> Vector3:
	var drop_location: Vector3 = camera_transformer.global_transform.origin - camera_transformer.global_transform.basis.z * 2
	drop_location.y -= 0.5
	return drop_location