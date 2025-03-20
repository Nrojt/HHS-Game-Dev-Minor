extends Node

func _ready():
	SignalManager.add_child_scene.connect(_on_add_child_scene)
	SignalManager.reload_children.connect(_on_reload_children)
	SceneManager.go_to_main_menu()


func _on_add_child_scene(scene_path: String, clear_other: bool) -> void:
	print("Adding to scene: %s, replacing: %s" % [scene_path, clear_other])
	# Clear existing children
	if clear_other:
		for child in get_children():
			child.queue_free()
	var scene: PackedScene = load(scene_path)
	child_scene_check_controll(scene.instantiate())


func _on_reload_children(caller: Node, delete_caller: bool) -> void:
	if delete_caller:
		if caller.is_inside_tree():
			remove_child(caller)
		else:
			printerr("Caller is not in tree")
		caller.queue_free()
		print("Children: " + str(get_children()))

	var children: Array = get_children().duplicate()

	for child in children:
		var scene_path = child.scene_file_path
		if scene_path:
			# Remove and clean up old child
			remove_child(child)
			child.queue_free()

			var new_child = load(scene_path).instantiate()
			child_scene_check_controll(new_child)


# function to check if the node is Control, and if so make a canvas layer as parent
func child_scene_check_controll(child: Node) -> void:
	if child is Control:
		print("Child is Control, adding CanvasLayer")
		var canvas_layer = CanvasLayer.new()
		canvas_layer.add_child(child)
		add_child(canvas_layer)
	else:
		add_child(child)
