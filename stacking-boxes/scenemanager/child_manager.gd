extends Node

func _ready():
	SignalManager.add_child_scene.connect(_on_add_child_scene)


func _on_add_child_scene(scene_path: String) -> void:
	print("Switching to scene: %s" % scene_path)
	GameManager.reset_variables()
	var scene: PackedScene = load(scene_path)
	# Clear existing children
	for child in get_children():
		child.queue_free()
	add_child(scene.instantiate())
