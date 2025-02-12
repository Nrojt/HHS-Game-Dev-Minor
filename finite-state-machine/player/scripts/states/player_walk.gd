extends PlayerState
class_name PlayerWalk

@export var MOVE_SPEED: float = 50.0
@export var RUN_TIMER_TIMEOUT: float = 1.0

@onready var run_timer := $RunTimer


func enter(_previous_state: GameEnums.PlayerStateType = GameEnums.PlayerStateType.UNDEFINED, _data: Dictionary = {}) -> void:
	run_timer.start(RUN_TIMER_TIMEOUT)


func physics_update(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * MOVE_SPEED * delta
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, MOVE_SPEED * delta)


func exit() -> void:
	run_timer.stop()


func _on_run_timer_timeout():
	print("walk timer timeout")
	transition.emit("run")
