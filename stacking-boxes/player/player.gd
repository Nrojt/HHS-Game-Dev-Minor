extends Node3D
@export var camera : Camera3D

@onready var remote_transform := $CameraTransformer

func _ready():
	if (!camera):
		push_error("No Camera3D set")
		
	remote_transform.remote_path = camera.get_path()
