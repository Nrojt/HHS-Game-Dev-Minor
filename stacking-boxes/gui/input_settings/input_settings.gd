extends Control

@onready var input_button_scene: PackedScene = preload("uid://c742rhgrg2wc2")
@onready var action_list: GridContainer = %ActionList

var config_path: String = "user://input_settings.cfg"
var remapping_event: InputEvent = null ## This somehow has to be set to the correct input event


func _ready():
	_load_input_settings()


func _input(event: InputEvent) -> void:
	if SaveManager.is_remapping:
		# Split this out by CreatedEnums.InputType, the contoller input should not be put in primary slot for example
		if event is InputEventKey || event is InputEventJoypadButton || (event is InputEventMouseButton and event.pressed) || event is InputEventJoypadMotion:
			if event is InputEventMouseButton && event.double_click:
				# converting double click to single click
				event.double_click = false
				

			InputMap.action_erase_event(SaveManager.action_to_remap, remapping_event)
			InputMap.action_add_event(SaveManager.action_to_remap, event)
			_save_input_settings()
			SaveManager.is_remapping = false
			SaveManager.action_to_remap = ""
			_create_action_list()
			

func _save_input_settings():
	var config = ConfigFile.new()

	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		var events: Array[InputEvent] = InputMap.action_get_events(action)

		config.set_value("input", action, events)

	config.save(config_path)


func _load_input_settings():
	# getting the default input map from project settings
	InputMap.load_from_project_settings()

	# loading the custom input map from the config file
	var config = ConfigFile.new()
	var error = config.load(config_path)

	if error == OK:
		for action in config.get_section_keys("input"):
			InputMap.action_erase_events(action)
			var events: Array[InputEvent] = config.get_value("input", action)
			# load events into input map
			InputMap.action_erase_events(action)
			for event in events:
				InputMap.action_add_event(action, event)

	_create_action_list()


func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()

	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		var action_row: MarginContainer = input_button_scene.instantiate()
		var action_label: Label = action_row.find_child("ActionLabel")
		var primary_input_label: Label = action_row.find_child("PrimaryInputLabel")
		var secondary_input_label: Label = action_row.find_child("SecondaryInputLabel")
		var controller_input_label: Label = action_row.find_child("ControllerInputLabel")

		action_label.text = action

		var events: Array[InputEvent] = InputMap.action_get_events(action)

		var primary_event: InputEvent = null
		var secondary_event: InputEvent = null
		var controller_event: InputEvent = null

		for event in events:
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				if not controller_event:
					controller_event = event
			else:
				if not primary_event:
					primary_event = event
				elif not secondary_event:
					secondary_event = event

		primary_input_label.text = _trim_mapping_suffix(primary_event.as_text()) if primary_event else "Unassigned"
		secondary_input_label.text = _trim_mapping_suffix(secondary_event.as_text()) if secondary_event else "Unassigned"
		controller_input_label.text = _trim_mapping_suffix(controller_event.as_text()) if controller_event else "Unassigned"

		action_list.add_child(action_row)


func _trim_mapping_suffix(mapping: String) -> String:
	var cleaned := mapping

	# Remove physical suffix
	if cleaned.ends_with(" (Physical)"):
		cleaned = cleaned.trim_suffix(" (Physical)")

	# If controller, remove everything outside of the brackets
	if cleaned.begins_with("Joypad"):
		var start_index: int = cleaned.find("(")
		var end_index: int = cleaned.find(")")
		if start_index != -1 and end_index != -1:
			cleaned = cleaned.substr(start_index + 1, end_index - start_index - 1)
		else:
			cleaned = cleaned.substr(0, cleaned.find(" "))

	# Trim any remaining whitespace
	return cleaned.strip_edges()


func _on_back_button_pressed():
	SaveManager.is_remapping = false
	_save_input_settings()
	queue_free()


func _on_reset_button_pressed():
	# Load default input map from project settings
	InputMap.load_from_project_settings()

	# Remove any saved custom input configuration
	if FileAccess.file_exists(config_path):
		DirAccess.remove_absolute(config_path)

	# Refresh the UI
	_create_action_list()
