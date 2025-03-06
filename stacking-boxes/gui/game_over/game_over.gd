extends Control

@onready var score_label := %ScoreLabel

func _ready() -> void:
	print(GameManager.max_height)
	score_label.text = "Score: %d"  % clamp(GameManager.max_height, 0 , abs(GameManager.max_height))
