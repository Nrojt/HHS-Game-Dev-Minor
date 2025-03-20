# Scene with a checkbox to switch settings with boolean values
extends HBoxContainer

# Emitted when the `CheckBox` state changes
signal toggled(is_button_pressed)

# The text of the Label should be changed to identify the setting
@export var title : String = "" : set = set_title
@export var checked: bool = false : set = set_checked  # Renamed for clarity

@onready var label: Label = $Label
@onready var check_box: CheckBox = $CheckBox

func _ready() -> void:
	# Connect the signal in code instead of editor
	check_box.toggled.connect(_on_check_box_toggled)

func _on_check_box_toggled(button_pressed: bool) -> void:
	toggled.emit(button_pressed)
	set_checked(button_pressed)  # Update the exported variable

func set_title(value: String) -> void:
	title = value
	if not is_node_ready():
		await ready
	label.text = title

func set_checked(value: bool) -> void:
	checked = value
	if not is_node_ready():
		await ready
	check_box.button_pressed = checked
