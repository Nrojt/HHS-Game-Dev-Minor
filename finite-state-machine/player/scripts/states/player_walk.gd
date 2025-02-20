extends PlayerState
class_name PlayerWalk

@export var RUN_TIMER_TIMEOUT: float = 1.0

@onready var run_timer: Timer = $RunTimer


func enter(_previous_state: StateEnums.PlayerStateType) -> void:
	run_timer.start(RUN_TIMER_TIMEOUT)


func physics_update(delta):
	super(delta)

	if player.is_on_floor():
		if player.velocity.x == 0:
			transition.emit(StateEnums.PlayerStateType.IDLE)
		if Input.is_action_just_pressed("jump"):
			transition.emit(StateEnums.PlayerStateType.JUMP)
	elif not player.is_on_floor():
		transition.emit(StateEnums.PlayerStateType.FALL)


func exit() -> void:
	run_timer.stop()


func _on_run_timer_timeout():
	transition.emit(StateEnums.PlayerStateType.RUN)
