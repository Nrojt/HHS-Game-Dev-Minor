extends Node

const CONFIG_PATH: String = "user://settings.cfg"
# Input remapping, signal would not work here, sine signal order is not guaranteed, which can cause multiple input buttons to be pressed at the same time or other bugs
var is_remapping: bool = false
var input_type: CreatedEnums.InputType
var action_to_remap: String = ""

var config: ConfigFile:
	get:
		if config == null:
			config = _get_config()
		return config


func _ready() -> void:
	_load_settings()


func _get_config() -> ConfigFile:
	var temp_config = ConfigFile.new()
	var err: int = temp_config.load(CONFIG_PATH)
	if not err == OK:
		# create empty config file
		if err == ERR_FILE_NOT_FOUND:
			printerr("Config file not found, creating a new one.")
			temp_config.save(CONFIG_PATH)
		else:
			push_error("Failed to get settings from %s. Error code: %d" % [CONFIG_PATH, err])
	return temp_config


func calculate_audio_db(value: float) -> float:
	if value == 0:
		return -85.0  # Mute
	# Convert a percentage value to decibels
	return (value / 100) * 85.0 - 85.0


func _load_settings() -> void:
	# Display settings												
	var resolution_from_save: Vector2i = config.get_value("display", "resolution_index", Vector2i(1920, 1080)) # Defaulting to 1920x1080
	get_window().set_size(resolution_from_save)

	var window_mode = config.get_value("display", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(window_mode)

	var vsync_enabled = config.get_value("display", "vsync", true)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)

	var scaling_value = config.get_value("display", "scaling_resolution", 100.0)
	get_window().scaling_3d_scale = scaling_value / 100

	var fsr_enabled = config.get_value("display", "fsr_enabled", false)
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if fsr_enabled else Viewport.SCALING_3D_MODE_BILINEAR

	# Audio settings
	var master_vol = config.get_value("audio", "master_volume", 100.0)
	AudioServer.set_bus_volume_db(0, calculate_audio_db(master_vol))

	var music_vol = config.get_value("audio", "music_volume", 100.0)
	AudioServer.set_bus_volume_db(2, calculate_audio_db(music_vol))

	var sound_vol = config.get_value("audio", "sound_volume", 100.0)
	AudioServer.set_bus_volume_db(1, calculate_audio_db(sound_vol))
