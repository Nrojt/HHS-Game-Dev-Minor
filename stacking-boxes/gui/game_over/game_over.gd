extends Control

# TODO: highscore is broken

const HIGH_SCORE_KEY: String = "high_score"
const SCORE_HEADING: String = "score"
const HIGH_SCORE_CONFIG_PATH: String = "user://score.cfg"
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel


func _ready() -> void:
	high_score_label.text = "Highscore: %d" %  _get_highscore()
	score_label.text = "Score: %d"  % clamp(GameManager.max_height, 0, abs(GameManager.max_height))


func _get_highscore() -> float:
	var config := ConfigFile.new()
	var high_score: float

	var err: int = config.load(HIGH_SCORE_CONFIG_PATH)
	if not err == OK:
		# create empty config file
		if err == ERR_FILE_NOT_FOUND:

			config.set_value(SCORE_HEADING, HIGH_SCORE_KEY, GameManager.max_height)
			config.save(HIGH_SCORE_CONFIG_PATH)
		else:
			push_error("Failed to get settings from %s. Error code: %d" % [HIGH_SCORE_KEY, err])
	else:
		high_score = config.get_value(SCORE_HEADING, HIGH_SCORE_KEY, 0.0)
		if GameManager.max_height > high_score:
			high_score = GameManager.max_height
			config.set_value(SCORE_HEADING, HIGH_SCORE_KEY, high_score)
			config.save(HIGH_SCORE_CONFIG_PATH)
	return high_score
