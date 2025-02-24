extends Node

func go_to_main_menu() -> void:
	SignalManager.add_child_scene.emit("uid://cb33156u20b8o", true)
	SignalManager.add_child_scene.emit("uid://dlnvdqqw7kash", false)