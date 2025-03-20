class_name SettingsDropDown extends HBoxContainer

# Emitted when dropdown selection changes with the selected index
signal option_selected(index: int)

# Text displayed next to the dropdown
@export var title: String = "Option" : set = set_title
# Available options for the dropdown
@export var options: Array[String] = ["Option 1", "Option 2"] : set = set_options
# Currently selected option index
@export var selected: int = 0 : set = set_selected

@onready var label: Label = $Label
@onready var options_dropdown: OptionButton = $OptionButton

func _ready() -> void:
	_update_dropdown()
	if not options_dropdown.item_selected.is_connected(_on_option_selected):
		options_dropdown.item_selected.connect(_on_option_selected)

func set_title(new_title: String) -> void:
	title = new_title
	if is_node_ready() and label:
		label.text = title

func set_options(new_options: Array[String]) -> void:
	options = new_options
	if is_node_ready():
		_update_dropdown()

func set_selected(new_index: int) -> void:
	selected = clamp(new_index, 0, options.size() - 1)
	if is_node_ready() and options_dropdown:
		options_dropdown.selected = selected

func _update_dropdown() -> void:
	if not options_dropdown:
		return

	options_dropdown.clear()
	for i in options.size():
		options_dropdown.add_item(options[i], i)
	options_dropdown.selected = selected

func _on_option_selected(index: int) -> void:
	set_selected(index)
	option_selected.emit(index)
