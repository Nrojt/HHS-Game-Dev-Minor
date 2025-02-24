extends Control

@onready var score_label := %ScoreLabel


# TODO: Controller support

func _ready() -> void:
	score_label.text = "Score: %d"  % clamp(GameManager.max_height, 0, abs(GameManager.max_height))


func _on_try_again_button_pressed() -> void:
	print("reloading level")
	SignalManager.reload_children.emit(self, true)


func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_main_menu_button_pressed():
	SceneManager.go_to_main_menu()
