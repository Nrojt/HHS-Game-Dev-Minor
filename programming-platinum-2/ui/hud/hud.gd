extends Control

@onready var time_label : Label = %TimeLabel

func _process(delta):
	if GameManager.game_active:
		time_label.text = "Time playing: %.2f" % GameManager.time_played
