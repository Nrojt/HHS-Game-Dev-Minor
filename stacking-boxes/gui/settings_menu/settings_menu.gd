extends Control

@onready var resolutions_drop_down: SettingsDropDown = %ResolutionsDropdown
@onready var screen_type_drop_down: SettingsDropDown = %ScreenTypeDropdown
@onready var master_volume_slider: SliderHbox = %MasterVolumeSlider
@onready var music_volume_slider: SliderHbox = %MusicVolumeSlider
@onready var sound_volume_slider: SliderHbox = %SoundVolumeSlider
@onready var v_sync_toggle: UiSettingsCheckBox = %VSyncToggle
@onready var fsr_toggle: UiSettingsCheckBox = %FSRToggle
@onready var scaling_resolution: SliderHbox = %ScalingResolution

# Resolutions
var resolutions: Array[Vector2i] = [
Vector2i(3840, 2160),
Vector2i(2560, 1440),
Vector2i(2440, 1400),
Vector2i(1920, 1080),
Vector2i(1280, 720),
Vector2i(1600, 900),
Vector2i(1440, 900),
Vector2i(1280, 720),
Vector2i(854, 480)
]

# Screen type options
var screen_types: Dictionary = {
	"Windowed": DisplayServer.WINDOW_MODE_WINDOWED,
	"Fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Exclusive Fullscreen": DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
	"Maximized": DisplayServer.WINDOW_MODE_MAXIMIZED
}


func _ready():
	SignalManager.set_button_visibility.emit(false)
	_populate_resolutions()
	_populate_screen_types()
	load_settings()


func _populate_resolutions() -> void:
	resolutions_drop_down.options_dropdown.clear()
	for res in resolutions:
		resolutions_drop_down.options_dropdown.add_item("%d x %d" % [res.x, res.y])


func _populate_screen_types() -> void:
	screen_type_drop_down.options_dropdown.clear()
	for mode in screen_types.keys():
		screen_type_drop_down.options_dropdown.add_item(mode)


func save_settings(section: String, key: String, value: Variant) -> void:
	var config: ConfigFile = SaveManager.get_config()
	config.set_value(section, key, value)
	var save_error: int = config.save(SaveManager.CONFIG_PATH)
	if save_error != OK:
		printerr("Failed to save settings to %s. Error code: %d" % [SaveManager.CONFIG_PATH, save_error])


func load_settings() -> void:
	var config: ConfigFile = SaveManager.get_config()

	# Display settings												
	var resolution_from_save: Vector2i = config.get_value("display", "resolution_index", Vector2i(1920, 1080)) # Defaulting to 1920x1080
	var resolution_index: int = resolutions.find(resolution_from_save)
	if resolution_index < 0 or resolution_index >= resolutions.size():
		printerr("Invalid resolution index: %d" % resolution_index)
		resolution_index = 2
	resolutions_drop_down.options_dropdown.select(resolution_index)

	_update_screen_type_selection()

	v_sync_toggle.check_box.button_pressed = config.get_value("display", "vsync", true)

	scaling_resolution.value = config.get_value("display", "scaling_resolution", 100.0)

	fsr_toggle.check_box.button_pressed = config.get_value("display", "fsr_enabled", false)

	# Audio settings
	master_volume_slider.value = config.get_value("audio", "master_volume", 100.0)

	music_volume_slider.value = config.get_value("audio", "music_volume", 100.0)

	sound_volume_slider.value = config.get_value("audio", "sound_volume", 100.0)


func _on_resolutions_dropdown_option_selected(index: int) -> void:
	var resolution: Vector2i = resolutions[index]
	get_window().set_size(resolution)
	save_settings("display", "resolution_index", resolution)


func _on_screen_type_dropdown_option_selected(index: int) -> void:
	var mode = screen_types.values()[index]
	DisplayServer.window_set_mode(mode)
	_update_screen_type_selection()
	save_settings("display", "window_mode", mode)


func _update_screen_type_selection() -> void:
	var current_mode: int = DisplayServer.window_get_mode()
	var index: int = screen_types.values().find(current_mode)
	if index >= 0:
		screen_type_drop_down.options_dropdown.select(index)


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, SaveManager.calculate_audio_db(value))
	save_settings("audio", "master_volume", value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, SaveManager.calculate_audio_db(value))
	save_settings("audio", "music_volume", value)


func _on_sound_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, SaveManager.calculate_audio_db(value))
	save_settings("audio", "sound_volume", value)


func _on_key_bind_button_pressed() -> void:
	SignalManager.add_child_scene.emit("uid://bwox3q508ewxc", false)


func _on_back_button_pressed() -> void:
	SignalManager.set_button_visibility.emit(true)
	queue_free()


func _on_v_sync_toggle_toggled(is_button_pressed: bool) -> void:
	print("vsync")
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if is_button_pressed else DisplayServer.VSYNC_DISABLED
	)
	save_settings("display", "vsync", is_button_pressed)


func _on_scaling_resolution_value_changed(value: float) -> void:
	var window := get_window()
	window.scaling_3d_scale = value / 100
	save_settings("display", "scaling_resolution", value)


func _on_fsr_toggle_toggled(is_button_pressed: bool) -> void:
	get_viewport().scaling_3d_mode = (
	Viewport.SCALING_3D_MODE_FSR if is_button_pressed else Viewport.SCALING_3D_MODE_BILINEAR
	)
	save_settings("display", "fsr_enabled", is_button_pressed)
