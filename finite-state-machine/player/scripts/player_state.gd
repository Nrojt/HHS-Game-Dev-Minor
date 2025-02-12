﻿extends Node
class_name PlayerState

@export var ANIMATION_NAME: String
@export var PLAYER: CharacterBody2D

var jump_available: bool = true
## Emitted when the state finishes and wants to transition to another state.
signal transition(next_state_path: String, data: Dictionary)


func init(player: CharacterBody2D) -> void:
	PLAYER = player


## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass


## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass


## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	pass


## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass