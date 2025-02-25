extends Control

func _ready():
	hide()
	SignalManager.resume_game.connect(on_resume)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		if get_tree().paused:
			on_resume()
		else:
			on_pause()


func on_resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	hide()


func on_pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	show()


func _exit_tree() -> void:
	get_tree().paused = false
