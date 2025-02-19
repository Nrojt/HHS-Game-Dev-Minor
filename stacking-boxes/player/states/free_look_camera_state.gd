extends CameraState

# TODO move these over to a settings menu
@export_range(0, 10, 0.01) var sensitivity: float = 3

@export_range(1, 100, 0.1) var boost_speed_multiplier: float = 3.0
@export var max_speed: float = 1000
@export var min_speed: float = 0.2


func exit() -> void:
	_velocity = default_velocity


func handle_input(event: InputEvent) -> void:
	# Handling mouse input here to have more control
	if event is InputEventMouseMotion:
		camera_transformer.rotation.y -= event.relative.x / 1000 * sensitivity
		camera_transformer.rotation.x -= event.relative.y / 1000 * sensitivity
		camera_transformer.rotation.x = clamp(camera_transformer.rotation.x, -PI/2, PI/2)


func update(delta) -> void:
	var direction := Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		0,
		Input.get_action_strength("backward") - Input.get_action_strength("forward")
	)

	if Input.is_action_pressed("speed_up"):
		_velocity = clamp(_velocity * speed_scale, min_speed, max_speed)
	elif Input.is_action_pressed("speed_down"):
		_velocity = clamp(_velocity / speed_scale, min_speed, max_speed)

	var right_stick_h := Input.get_axis("look_left", "look_right")
	var right_stick_v := Input.get_axis("look_up", "look_down")

	camera_transformer.rotation.y -= right_stick_h * delta * sensitivity
	camera_transformer.rotation.x -= right_stick_v * delta * sensitivity
	camera_transformer.rotation.x = clamp(camera_transformer.rotation.x, -PI/2, PI/2)

	if Input.is_action_pressed("sprint"):
		camera_transformer.translate(direction * _velocity * delta * boost_speed_multiplier)
	else:
		camera_transformer.translate(direction * _velocity * delta)

	if Input.is_action_just_pressed("switch_camera_state"):
		transition.emit(CreatedEnums.CameraStateType.GAMEPLAY)