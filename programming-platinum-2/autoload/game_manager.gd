extends Node

signal game_started
signal placed_draggable(placed_draggable : Draggable)

var _default_movement_speed := 0.4

var current_draggable : Draggable = null :
	set(value):
		current_draggable = value
var movement_speed: float = _default_movement_speed
var time_played: float = 0.0
# This threshold defines how often the speed increases
var movement_speed_increase_interval: float = 1.0
var time_since_last_speed_increase: float = 0.0

var game_active := false :
	set(value):
		game_active = value
		if game_active:
			# Reset the time played and speed increase timer when the game starts
			time_played = 0.0
			time_since_last_speed_increase = 0.0
			movement_speed = _default_movement_speed
			game_started.emit()
		else:
			current_draggable.queue_free()
			current_draggable = null
			UiManager.ui_state_changed.emit(UiManager.UIState.GAME_OVER)
			print("Game stopped")

func _process(delta):
	if game_active:
		time_played += delta
		time_since_last_speed_increase += delta
		# Check if enough time has passed to increase the speed
		if time_since_last_speed_increase >= movement_speed_increase_interval:
			movement_speed += 0.1
			# Reset the timer after increasing the speed
			time_since_last_speed_increase = 0.0
