extends CameraState

# TODO move these over to a settings menu
@export_range(0, 10, 0.01) var sensitivity : float = 3
@export_range(0, 1000, 0.1) var default_velocity : float = 5
@export_range(0, 10, 0.01) var speed_scale : float = 1.17
@export_range(1, 100, 0.1) var boost_speed_multiplier : float = 3.0
@export var max_speed : float = 1000
@export var min_speed : float = 0.2

@onready var _velocity: float = default_velocity

func handle_input(event : InputEvent) -> void:

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			camera_transformer.rotation.y -= event.relative.x / 1000 * sensitivity
			camera_transformer.rotation.x -= event.relative.y / 1000 * sensitivity
			camera_transformer.rotation.x = clamp(camera_transformer.rotation.x, PI/-2, PI/2)

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # increase fly velocity
				_velocity = clamp(_velocity * speed_scale, min_speed, max_speed)
			MOUSE_BUTTON_WHEEL_DOWN: # decrease fly velocity
				_velocity = clamp(_velocity / speed_scale, min_speed, max_speed)
			MOUSE_BUTTON_LEFT:
				# spawn droppable in front of camera
				var spawn_location := camera_transformer.global_position - camera_transformer.global_transform.basis.z * 2
				SignalManager.spawn_droppable.emit(spawn_location)

func update(delta) -> void:
		
	var direction := Vector3(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_E)) - float(Input.is_physical_key_pressed(KEY_Q)), 
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	).normalized()
	
	if Input.is_physical_key_pressed(KEY_SHIFT): # boost
		camera_transformer.translate(direction * _velocity * delta * boost_speed_multiplier)
	else:
		camera_transformer.translate(direction * _velocity * delta)
