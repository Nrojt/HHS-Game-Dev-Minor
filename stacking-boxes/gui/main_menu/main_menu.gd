extends Control

@onready var button_container: VBoxContainer = %ButtonsVBox


func _ready():
	SignalManager.set_button_visibility.connect(_on_set_button_visibility)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func _on_set_button_visibility(visible: bool) -> void:
	button_container.visible = visible
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
