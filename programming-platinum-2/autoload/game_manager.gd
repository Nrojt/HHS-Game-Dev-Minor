extends Node

signal placed_draggable(placed_draggable : Draggable)

var _default_movement_speed := 0.4

var current_draggable : Draggable = null :
	set(value):
		print("Draggable in gameManager: " + value.name)
		current_draggable = value
var movement_speed: float = _default_movement_speed
var time_played: float = 0.0
# This threshold defines how often the speed increases
var movement_speed_increase_interval: float = 1.0
var time_since_last_speed_increase: float = 0.0

var game_active := true

func _process(delta):
	if game_active:
		time_played += delta
		time_since_last_speed_increase += delta
		# Check if enough time has passed to increase the speed
		if time_since_last_speed_increase >= movement_speed_increase_interval:
			movement_speed += 0.1
			# Reset the timer after increasing the speed
			time_since_last_speed_increase = 0.0
