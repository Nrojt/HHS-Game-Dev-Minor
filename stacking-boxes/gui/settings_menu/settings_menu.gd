extends Control

@onready var resolutions_drop_down : SettingsDropDown = %ResolutionsDropdown
@onready var screen_type_drop_down : SettingsDropDown = %ScreenTypeDropdown

# Resolutions
var resolutions : Array[Vector2i]= [
					Vector2i(3840, 2160),
					Vector2i(2560, 1440),
					Vector2i(1920, 1080),
					Vector2i(1280, 720),
					Vector2i(1366, 768),
					Vector2i(1600, 900),
					Vector2i(1440, 900),
					Vector2i(1280, 800),
					Vector2i(854, 480)
				   ]

# Screen type options
var screen_types : Dictionary[String, DisplayServer.WindowMode] = {"Windowed": DisplayServer.WINDOW_MODE_WINDOWED, "Fullscreen" : DisplayServer.WINDOW_MODE_FULLSCREEN, "Exclusive Fullscreen" : DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, "Maximized": DisplayServer.WINDOW_MODE_MAXIMIZED}

func _ready():
	# Initialize resolution dropdown
	_populate_resolutions()
	# Initialize screen type dropdown
	_populate_screen_types()
	# Set initial selection to current window mode
	_update_screen_type_selection()

func _populate_resolutions() -> void:
	resolutions_drop_down.options_dropdown.clear()
	for res in resolutions:
		resolutions_drop_down.options_dropdown.add_item("%d x %d" % [res.x, res.y])

func _populate_screen_types() -> void:
	screen_type_drop_down.options_dropdown.clear()
	for mode in screen_types.keys():
		screen_type_drop_down.options_dropdown.add_item(mode)

func _on_resolutions_dropdown_option_selected(index: int) -> void:
	var selected_res: Vector2i =  resolutions[index]
	print(selected_res)
	DisplayServer.window_set_size(selected_res)

func _on_screen_type_dropdown_option_selected(index: int) -> void:
	var mode : DisplayServer.WindowMode = screen_types.values()[index]
	DisplayServer.window_set_mode(mode)



	# Save mode to config
	_update_screen_type_selection()

func _update_screen_type_selection() -> void:
	var current_mode := DisplayServer.window_get_mode()
	screen_type_drop_down.options_dropdown.selected = current_mode


func _on_master_volume_slider_value_changed(value: float) -> void:
	# Convert 0-100 slider range to -85dB (mute) to 0dB (full volume)
	var db_value := (value / 100) * 85 - 85
	AudioServer.set_bus_volume_db(0, db_value)

func _on_key_bind_button_pressed() -> void:
	SignalManager.add_child_scene.emit("uid://bwox3q508ewxc", false)

func _on_back_button_pressed() -> void:
	# Close settings menu
	queue_free()

func _on_v_sync_toggle_toggled(is_button_pressed: bool) -> void:
	# Set V-Sync mode based on toggle state
	if is_button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_scaling_resolution_value_changed(value: float) -> void:
	# Set window scaling factor (0.5 = 50%, 1.0 = 100%, 2.0 = 200%)
	var window := get_window()
	window.scaling_3d_scale = value / 100
	

func _on_fsr_toggle_toggled(is_button_pressed: bool) -> void:
	# Enable/disable FSR 2.0 upscaling
	if is_button_pressed:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
	else:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR


func _on_music_volume_slider_value_changed(value: float) -> void:
	var db_value := (value / 100) * 85 - 85
	AudioServer.set_bus_volume_db(2 , db_value)


func _on_sound_volume_slider_value_changed(value: float) -> void:
	var db_value := (value / 100) * 85 - 85
	AudioServer.set_bus_volume_db(1, db_value)
