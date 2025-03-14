extends Node3D
@export var camera: Camera3D

@onready var remote_transform := $CameraTransformer

@export var death_y: float = -10


func _ready():
	if (!camera):
		push_error("No Camera3D set")

	remote_transform.remote_path = camera.get_path()


func _process(_delta: float) -> void:
	if GameManager.current_droppable != null && Input.is_action_just_pressed("spawn_droppable_button"):
		SignalManager.drop_current_droppable.emit()

	if (GameManager.current_droppable && GameManager.current_droppable.global_position.y <= death_y):
		print("Droppable off the map")
		SignalManager.player_death.emit()
		GameManager.current_droppable.queue_free()
		_on_player_death()


func _on_player_death() -> void:
	queue_free()
