extends PlayerState
class_name PlayerWalk

@export var MOVE_SPEED: float = 2500.0
@export var RUN_TIMER_TIMEOUT: float = 1.0

@onready var run_timer := $RunTimer


func enter(_previous_state: StateEnums.PlayerStateType = StateEnums.PlayerStateType.UNDEFINED, _data: Dictionary = {}) -> void:
	print("PlayerWalk: Enter")
	run_timer.start(RUN_TIMER_TIMEOUT)


func physics_update(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * MOVE_SPEED * delta
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, MOVE_SPEED * delta)

	if player.is_on_floor()    && player.velocity.x == 0:
		transition.emit(StateEnums.PlayerStateType.IDLE)
	elif not player.is_on_floor():
		transition.emit(StateEnums.PlayerStateType.FALL)


func exit() -> void:
	run_timer.stop()


func _on_run_timer_timeout():
	transition.emit("run")
