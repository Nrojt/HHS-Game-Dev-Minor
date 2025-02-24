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
signal add_child_scene(path: String, clear_other: bool)
signal reload_children(caller: Node, delete_caller: bool)