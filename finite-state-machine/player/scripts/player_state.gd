extends Node
class_name PlayerState

@export var ANIMATION_NAME: String
@export var STATE_TYPE: StateEnums.PlayerStateType

@onready var animated_sprite := $AnimatedSprite2D

var jump_available: bool = true
var player: CharacterBody2D
## Emitted when the state finishes and wants to transition to another state.
signal transition(next_state: StateEnums.PlayerStateType, data: Dictionary)


func init(_player: CharacterBody2D) -> void:
	player = _player


## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass


## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_previous_state: StateEnums.PlayerStateType = StateEnums.PlayerStateType.UNDEFINED, _data := {}) -> void:
	pass


## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass
