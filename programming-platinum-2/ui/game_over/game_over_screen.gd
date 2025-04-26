extends Control

@onready var score_label : RichTextLabel = %ScoreLabel

func _ready() -> void:
	score_label.text = "[color=#ffffff][b]You killed the enemy AI in[/b][/color] [color=#00ff99][b]%.2f[/b][/color]" % GameManager.time_played



func _on_quit_game_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	UiManager.ui_state_changed.emit(UiManager.UIState.MAIN_MENU)
