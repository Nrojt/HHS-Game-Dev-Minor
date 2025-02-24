extends Node3D
@export var camera: Camera3D

@onready var remote_transform := $CameraTransformer


# TODO: fix, the first droppable immediatly drops instead of holding state first

func _ready():
	if (!camera):
		push_error("No Camera3D set")

	remote_transform.remote_path = camera.get_path()
	SignalManager.player_death.connect(_on_player_death)


func _process(_delta: float) -> void:
	# TODO: Move somwhere else, most likely menu
	if Input.is_action_just_pressed("escape"):
		# change mouse mode to opposite of current #TODO
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if GameManager.current_droppable == null:
		var drop_location: Vector3 = remote_transform.global_transform.origin - remote_transform.global_transform.basis.z * 2
		SignalManager.spawn_droppable.emit(drop_location)
		return

	if Input.is_action_just_pressed("spawn_droppable_button"):
		SignalManager.drop_current_droppable.emit()

	if GameManager.current_droppable.is_holding:
		var under_camera_location: Vector3 = remote_transform.global_position - remote_transform.global_transform.basis.z * 2
		SignalManager.move_current_droppable.emit(under_camera_location)


func _on_player_death() -> void:
	queue_free()