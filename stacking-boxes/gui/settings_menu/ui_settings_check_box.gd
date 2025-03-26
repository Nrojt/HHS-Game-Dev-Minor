# Scene with a checkbox to switch settings with boolean values
class_name UiSettingsCheckBox
extends HBoxContainer

# Emitted when the `CheckBox` state changes
signal toggled(is_button_pressed)
# The text of the Label should be changed to identify the setting
@export var title: String = "": set = set_title

@onready var label: Label = $Label
@onready var check_box: CheckBox = $CheckBox

func _on_check_box_toggled(button_pressed: bool) -> void:
	toggled.emit(button_pressed)


func set_title(value: String) -> void:
	title = value
	if not is_node_ready():
		await ready
	label.text = title
