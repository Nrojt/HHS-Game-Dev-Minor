extends Node

var droppable_scenes: Array[PackedScene] = []
const DROPPABLE_SCRIPT_PATH: String = "res://scripts/droppable_base.gd"


func _ready() -> void:
	SignalManager.spawn_droppable.connect(_on_spawn_droppable)
	droppable_scenes = _get_droppable_scenes()


func _on_spawn_droppable(location: Vector3) -> void:
	if(GameManager.current_droppable):
		print("Cannot spawn droppable while another is still active")
		return

	if droppable_scenes.is_empty():
		push_error("No droppable scenes found in res://droppables/")
		return

	var random_scene: PackedScene = droppable_scenes.pick_random()
	var droppable := random_scene.instantiate()

	# Validate node type before adding script
	if droppable is RigidBody3D:
		var script: GDScript = load(DROPPABLE_SCRIPT_PATH)
		droppable.set_script(script)
	else:
		push_error("Droppable root node must be RigidBody3D")
		droppable.queue_free()
		return

	droppable.gravity_scale = 0

	get_parent().add_child(droppable)
	droppable.global_transform.origin = location

	GameManager.current_droppable = droppable


func _get_droppable_scenes() -> Array[PackedScene]:
	var scenes: Array[PackedScene] = []

	# Get all files in droppables directory
	var files := DirAccess.get_files_at("res://droppables/")
	for file in files:
		if file.ends_with(".tscn"):
			var scene_path := "res://droppables/%s" % file
			var scene: PackedScene = load(scene_path)
			if scene:
				scenes.append(scene)

	return scenes
