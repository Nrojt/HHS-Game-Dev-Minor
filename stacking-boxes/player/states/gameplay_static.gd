extends CameraState

@export var camera_location : Vector3
@export var sensitivity : float = 2.0 
@export var rotation_limits : float = PI/1.5

# Store initial rotation for reference
var initial_rotation : Vector3

func enter() -> void:
	camera_transformer.global_position = camera_location
	camera_transformer.global_rotation = Vector3(0, 0, 0)
	initial_rotation = camera_transformer.global_rotation
	SignalManager.update_camera_height.connect(_on_update_camera_height)

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_transformer.rotation.x -= event.relative.y / 1000 * sensitivity
		_clamp_rotation()
		

func update(delta) -> void:
	# Keep the camera at its fixed position 
	camera_transformer.global_position = camera_location
	

	var right_stick_v := Input.get_axis("look_up", "look_down")
	
	camera_transformer.rotation.x -= right_stick_v * delta * sensitivity
	_clamp_rotation()

	# Handle droppable spawning
	if GameManager.current_droppable == null:
		SignalManager.spawn_droppable.emit(camera_transformer_location)

	# Handle camera state switching
	if Input.is_action_just_pressed("switch_camera_state"):
		transition_next.emit()

func _on_update_camera_height(height: float) -> void:
	# updating camera_transformer_location height based on the pile height
	camera_location.y += height
	print("Camera height updated to: ", camera_transformer_location.y)

func _clamp_rotation():
	var clamp_value: float = initial_rotation.x + rotation_limits
	camera_transformer.rotation.x = clamp(camera_transformer.rotation.x, -clamp_value, clamp_value)
