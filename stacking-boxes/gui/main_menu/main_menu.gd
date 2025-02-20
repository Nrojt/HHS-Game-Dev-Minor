extends Control

func _ready():
	SignalManager.add_child_scene.emit("uid://dlnvdqqw7kash")


func _on_start_game_button_pressed():
	get_tree().change_scene_to_file("uid://b14icr4kflsvi")
