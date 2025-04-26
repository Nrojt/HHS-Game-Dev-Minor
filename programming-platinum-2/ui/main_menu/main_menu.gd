extends Control


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()


func _on_play_game_button_pressed() -> void:
	UiManager.ui_state_changed.emit(UiManager.UIState.PLAYING)
	GameManager.game_active = true
