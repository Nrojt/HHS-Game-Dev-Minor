extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.load_scene.connect(_on_load_scene)
	SignalManager.load_scene_as_child.connect(_on_load_scene_as_child)


func _on_load_scene(current_scene: Node , scene_path: String) -> void:
	_deferred_goto_scene( current_scene, scene_path)

func _deferred_goto_scene(current_scene : Node, scene_path : String):
	if(!current_scene):
		push_error("No scene to replace")
	
	if(!scene_path):
		push_error("No scene to load")
	
	# It is now safe to remove the current scene.
	if current_scene:
		current_scene.queue_free()
		
	# Load the new scene.
	var s: Resource = load(scene_path)

	# Instance the new scene.
	var new_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(new_scene)

func _on_load_scene_as_child(current_scene: Node, scene_path: String) -> void:
	_deferred_add_scene(current_scene, scene_path)
func _deferred_add_scene(current_scene : Node, scene_path : String):
	if(!current_scene):
		push_error("No scene to replace")

	if(!scene_path):
		push_error("No scene to load")

	# Load the new scene.
	var s: Resource = load(scene_path)

	# Instance the new scene.
	var new_scene = s.instantiate()

	print("adding as child")
	# Add it to the active scene, as child of root.
	current_scene.add_child(new_scene)
