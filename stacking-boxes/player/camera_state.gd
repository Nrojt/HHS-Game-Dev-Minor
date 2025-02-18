extends Node
class_name CameraState

@export var STATE_TYPE: CreatedEnums.CameraStateType
@export_range(0, 10, 0.01) var speed_scale : float = 1.17
@export_range(0, 1000, 0.1) var default_velocity : float = 5
@onready var _velocity: float = default_velocity

var camera_transformer: RemoteTransform3D

## Emitted when the state finishes and wants to transition to another state.
signal transition(next_state: CreatedEnums.CameraStateType)

func handle_input(event : InputEvent) -> void:
	pass

# Used to pass a reference of the player to the state.
func init(_transformer: RemoteTransform3D) -> void:
	camera_transformer = _transformer


## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_update(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	pass


## Called by the state machine upon changing the active state.
func enter() -> void:
	pass


## Called by the state machine before changing the active state.
func exit() -> void:
	pass
