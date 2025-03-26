extends Control

const HIGH_SCORE_KEY: String = "high_score"
const SCORE_SECTION: String = "score"
const HIGH_SCORE_PATH: String = "user://scores.cfg"
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel

var config := _load_or_create_config()


func _ready() -> void:
	_update_score_display()


func _update_score_display() -> void:
	var current_score: int = max(0, floor(GameManager.max_height))
	var high_score: int = _get_high_score(current_score)

	score_label.text = "Score: %d" % current_score
	high_score_label.text = "Highscore: %d" % high_score


func _get_high_score(current_score: int) -> int:

	var high_score: int = config.get_value(SCORE_SECTION, HIGH_SCORE_KEY, 0.0)
	if current_score > high_score:
		high_score = current_score
		_save_current_score(high_score)
	return high_score


func _save_current_score(high_score: int) -> void:
	var current_score: int = floor(GameManager.max_height)

	print("Current score: %d High score: %d" % [current_score, high_score])
	config.set_value(SCORE_SECTION, HIGH_SCORE_KEY, current_score)
	_safe_save_config(config)


func _load_or_create_config() -> ConfigFile:
	var temp_config := ConfigFile.new()
	var err: int = temp_config.load(HIGH_SCORE_PATH)

	if err == ERR_FILE_NOT_FOUND:
		temp_config.set_value(SCORE_SECTION, HIGH_SCORE_KEY, 0.0)
		_safe_save_config(temp_config)
	elif err != OK:
		push_error("Failed to load high score config: Error %d" % err)

	return temp_config


func _safe_save_config(temp_config: ConfigFile) -> void:
	var err := temp_config.save(HIGH_SCORE_PATH)
	if err != OK:
		push_error("Failed to save high score: Error %d" % err)
