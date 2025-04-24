extends Control

@onready var time_label : Label = $TimeLabel

func _process(delta):
	if GameManager.game_active:
		time_label.text = "%.2f" % GameManager.time_played
