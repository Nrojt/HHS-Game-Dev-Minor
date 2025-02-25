extends Node

var droppable_scenes: Array[PackedScene] = []
const DROPPABLE_SCRIPT_PATH: String = "res://scripts/droppable_base.gd"


func _ready() -> void:
	SignalManager.spawn_droppable.connect(_on_spawn_droppable)
	get_droppable_scenes()


func _on_spawn_droppable(location: Vector3) -> void:
	print("Spawning droppable at: ", location)
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
	droppable.global_transform.basis = Transform3D.IDENTITY.basis

	GameManager.current_droppable = droppable


func get_droppable_scenes() -> void:
	# Get all files in droppables directory
	var dir := DirAccess.open("res://droppables/")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			# Remove .remap suffix if present
			file_name = file_name.replace('.remap', '')

			if file_name.get_extension() == "tscn":
				var scene_path := "res://droppables/%s" % file_name
				# Use ResourceLoader
				var scene: PackedScene = ResourceLoader.load(scene_path)
				if scene:
					droppable_scenes.append(scene)
			file_name = dir.get_next()
		dir.list_dir_end()

		
