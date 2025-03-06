extends Node3D
@export var camera: Camera3D

@onready var remote_transform := $CameraTransformer


func _ready():
	if (!camera):
		push_error("No Camera3D set")

	remote_transform.remote_path = camera.get_path()
	SignalManager.player_death.connect(_on_player_death)


func _process(_delta: float) -> void:
	if GameManager.current_droppable != null && Input.is_action_just_pressed("spawn_droppable_button"):
		SignalManager.drop_current_droppable.emit()


func _on_player_death() -> void:
	queue_free()
