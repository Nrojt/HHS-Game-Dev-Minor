extends PlayerState
class_name PlayerIdle

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass


func enter(_previous_state: GameEnums.PlayerStateType = GameEnums.PlayerStateType.UNDEFINED, _data: Dictionary = {}) -> void:
	player.velocity.x = 0
