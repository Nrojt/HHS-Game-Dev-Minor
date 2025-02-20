extends Control

# TODO: Controller support


func _on_try_again_button_pressed() -> void:
	get_tree().reload_current_scene()
