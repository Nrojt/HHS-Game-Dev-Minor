extends Control

@onready var input_button_scene: PackedScene = preload("uid://c742rhgrg2wc2")
@onready var action_list: GridContainer = %ActionList
@onready var error_text: Label = %ErrorText

var config_heading: String = "input"


func _ready():
	_load_input_settings()


func _input(event: InputEvent) -> void:
	if not SaveManager.is_remapping || event is InputEventMouseMotion:
		return

	var input_type = SaveManager.input_type
	var action = SaveManager.action_to_remap

	if not _is_valid_event_for_input_type(event, input_type):
		error_text.text = "Invalid input event for this action"
		return

	if event is InputEventMouseButton and event.double_click:
		event = event.duplicate()
		event.double_click = false

	if _is_event_already_assigned(event, action):
		error_text.text = "Input event already assigned to another action"
		return

	var current_events: Array[InputEvent] = InputMap.action_get_events(action)
	var split_events: Dictionary = _split_events_by_type(current_events)

	var old_event: InputEvent = _get_event_to_replace(split_events, input_type)
	if old_event:
		InputMap.action_erase_event(action, old_event)

	InputMap.action_add_event(action, event)
	_finalize_remapping()


func _save_input_settings():
	var config: ConfigFile = SaveManager.config

	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		config.set_value(config_heading, action, InputMap.action_get_events(action))

	config.save(SaveManager.CONFIG_PATH)


func _load_input_settings():
	InputMap.load_from_project_settings()
	var config: ConfigFile = SaveManager.config

	if config.load(SaveManager.CONFIG_PATH) == OK:
		for action in config.get_section_keys(config_heading):
			InputMap.action_erase_events(action)
			for event in config.get_value(config_heading, action):
				InputMap.action_add_event(action, event)

	_create_action_list()


func _create_action_list():
	error_text.text = ""
	# Clear existing children
	for child in action_list.get_children():
		child.queue_free()

	# Add header labels to GridContainer
	action_list.add_child(_create_header_label("Action", HORIZONTAL_ALIGNMENT_LEFT))
	action_list.add_child(_create_header_label("Primary Input", HORIZONTAL_ALIGNMENT_CENTER))
	action_list.add_child(_create_header_label("Secondary Input", HORIZONTAL_ALIGNMENT_CENTER))
	action_list.add_child(_create_header_label("Controller Input", HORIZONTAL_ALIGNMENT_RIGHT))

	# Add action rows
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		var action_row: Node = input_button_scene.instantiate()
		var split_events: Dictionary = _split_events_by_type(InputMap.action_get_events(action))

		action_row.find_child("ActionLabel").text = action
		_set_label_text(action_row, "PrimaryPanelContainer", split_events.primary, action)
		_set_label_text(action_row, "SecondaryPanelContainer", split_events.secondary, action)
		_set_label_text(action_row, "ControllerPanelContainer", split_events.controller, action)

		# Proper reparenting sequence
		for button_child in action_row.get_children():
			action_row.remove_child(button_child)  # Remove from original parent
			action_list.add_child(button_child)   # Add to new parent

		action_row.queue_free()  # Clean up the empty container


func _trim_mapping_suffix(mapping: String) -> String:
	var cleaned: String = mapping.replace(" (Physical)", "")

	if cleaned.begins_with("Joypad"):
		var start: int = cleaned.find("(")
		var end: int = cleaned.find(")")
		if start != -1 and end != -1:
			cleaned = cleaned.substr(start + 1, end - start - 1)
		else:
			cleaned = cleaned.substr(0, cleaned.find(" "))

	return cleaned.strip_edges()


func _on_back_button_pressed():
	SaveManager.is_remapping = false
	_save_input_settings()
	queue_free()


func _on_reset_button_pressed():
	SaveManager.is_remapping = false
	SaveManager.action_to_remap = ""
	InputMap.load_from_project_settings()

	if FileAccess.file_exists(SaveManager.CONFIG_PATH):
		DirAccess.remove_absolute(SaveManager.CONFIG_PATH)

	_create_action_list()


func _is_valid_event_for_input_type(event: InputEvent, input_type: int) -> bool:
	match input_type:
		CreatedEnums.InputType.CONTROLLER:
			return event is InputEventJoypadButton or event is InputEventJoypadMotion
		_:
			return event is InputEventMouseButton or event is InputEventKey


func _split_events_by_type(events: Array[InputEvent]) -> Dictionary:
	var result: Dictionary = {
		primary = null,
		secondary = null,
		controller = null
	}

	for event in events:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if not result.controller:
				result.controller = event
		else:
			if not result.primary:
				result.primary = event
			elif not result.secondary:
				result.secondary = event

	return result


func _is_event_already_assigned(event: InputEvent, current_action: String) -> bool:
	for action in InputMap.get_actions():
		if action == current_action:
			continue

		for existing_event in InputMap.action_get_events(action):
			if existing_event.is_match(event):
				return true

	return false


func _get_event_to_replace(split_events: Dictionary, input_type: int) -> InputEvent:
	match input_type:
		CreatedEnums.InputType.PRIMARY: return split_events.primary
		CreatedEnums.InputType.SECONDARY: return split_events.secondary
		CreatedEnums.InputType.CONTROLLER: return split_events.controller
		_: return null


func _finalize_remapping():
	_save_input_settings()
	SaveManager.is_remapping = false
	SaveManager.action_to_remap = ""
	_create_action_list()


func _set_label_text(row: Node, container_name: String, event: InputEvent, action_to_remap: String = ""):
	# Helper to safely set text on labels with fallback
	var panel: RemapPanel = row.find_child(container_name)
	if event:
		panel.label_path.text = _trim_mapping_suffix(event.as_text())
	else:
		panel.label_path.text = "Unassigned"
	panel.action_to_remap = action_to_remap


func _create_header_label(text: String, horizontal_alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = horizontal_alignment
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 20)
	return label
