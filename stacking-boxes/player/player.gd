extends Node3D
@export var camera: Camera3D
@export var death_y: float = -10

@onready var remote_transform := $CameraTransformer


func _ready():
	if (!camera):
		push_error("No Camera3D set")

	remote_transform.remote_path = camera.get_path()


func _process(_delta: float) -> void:
	# TODO: Move somwhere else, most likely menu
	if Input.is_action_just_pressed("escape"):
		# change mouse mode to opposite of current
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if GameManager.current_droppable == null:
		SignalManager.spawn_droppable.emit(remote_transform.global_transform.origin)
		return
	
	if Input.is_action_just_pressed("spawn_droppable_button"):
		SignalManager.drop_current_droppable.emit()
		

	if GameManager.current_droppable.is_holding:
		var under_camera_location: Vector3 = remote_transform.global_position - remote_transform.global_transform.basis.z * 2
		SignalManager.move_current_droppable.emit(under_camera_location)


	if (GameManager.current_droppable.global_position.y <= death_y):
		print("Droppable off the map")
		SignalManager.player_death.emit()
		GameManager.current_droppable.queue_free()
		queue_free()

	
		
