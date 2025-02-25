extends Control

@onready var score_label := %ScoreLabel


# TODO: Controller support

func _ready() -> void:
	score_label.text = "Score: %d"  % clamp(GameManager.max_height, 0, abs(GameManager.max_height))
