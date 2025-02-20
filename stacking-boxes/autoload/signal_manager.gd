extends Node

# Droppable signals
signal spawn_droppable(location: Vector3)
signal drop_current_droppable()
signal move_current_droppable(location: Vector3)

# Camera signals
signal update_camera_height(height: float)

# Player signals
signal player_death()
	
# Scene signals
signal load_scene(current_scene: Node, scene_path: String)
signal load_scene_as_child(current_scene: Node, scene_path: String)