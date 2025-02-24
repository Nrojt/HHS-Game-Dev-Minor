extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_game_button_pressed():
	SignalManager.add_child_scene.emit("uid://b14icr4kflsvi", true)


func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
