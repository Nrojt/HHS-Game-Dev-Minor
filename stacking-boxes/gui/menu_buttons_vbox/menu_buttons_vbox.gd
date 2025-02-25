extends VBoxContainer

@onready var start_game_button := $StartGameButton
@onready var settings_button := $SettingsButton
@onready var quit_button := $QuitButton
@onready var try_again_button := $TryAgainButton
@onready var main_menu_button := $MainMenuButton
@onready var resume_game_button := $ResumeButton

@export_category("Button Visibility")
@export var start_game_button_visible := false
@export var settings_button_visible := false
@export var quit_button_visible := false
@export var try_again_button_visible := false
@export var main_menu_button_visible := false
@export var resume_game_button_visible := false


func _ready():
	# setting button visibility
	start_game_button.visible = start_game_button_visible
	settings_button.visible = settings_button_visible
	quit_button.visible = quit_button_visible
	try_again_button.visible = try_again_button_visible
	main_menu_button.visible = main_menu_button_visible
	resume_game_button.visible = resume_game_button_visible

	focus_first_visible_button()

func focus_first_visible_button():
	for button in get_children():
		if button.visible:
			button.grab_focus()
			break


func _on_start_game_button_pressed():
	SceneManager.go_to_game()


func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_settings_button_pressed():
	print("Not yet implemented")


func _on_try_again_button_pressed():
	SceneManager.go_to_game()


func _on_main_menu_button_pressed():
	SceneManager.go_to_main_menu()


func _on_resume_button_pressed():
	SignalManager.resume_game.emit()
