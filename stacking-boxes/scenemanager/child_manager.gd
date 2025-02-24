extends Node

func _ready():
	SignalManager.add_child_scene.connect(_on_add_child_scene)
	_on_add_child_scene("uid://cb33156u20b8o", false)
	_on_add_child_scene("uid://dlnvdqqw7kash", false)


func _on_add_child_scene(scene_path: String, clear_other: bool) -> void:
	print("Switching to scene: %s" % scene_path)
	GameManager.reset_variables()
	# Clear existing children
	if clear_other:
		for child in get_children():
			child.queue_free()
	var scene: PackedScene = load(scene_path)
	add_child(scene.instantiate())
