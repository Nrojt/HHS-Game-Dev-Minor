extends Node
class_name PlayerState

@export var ANIMATION_NAME: String
@export var STATE_TYPE: StateEnums.PlayerStateType
@export var MOVE_SPEED: float = 150.0

@onready var animated_sprite := $AnimatedSprite2D

var player: CharacterBody2D
## Emitted when the state finishes and wants to transition to another state.
signal transition(next_state: StateEnums.PlayerStateType)


# Used to pass a reference of the player to the state.
func init(_player: CharacterBody2D) -> void:
	player = _player


## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_update(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * MOVE_SPEED * delta
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, MOVE_SPEED * delta)


## Called by the state machine upon changing the active state.
func enter(_previous_state: StateEnums.PlayerStateType = StateEnums.PlayerStateType.UNDEFINED) -> void:
	pass


## Called by the state machine before changing the active state.
func exit() -> void:
	pass
