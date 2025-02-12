extends Node

@export var starting_state: PlayerState
@export var player: CharacterBody2D

@onready
var current_state: PlayerState = get_initial_state()
@onready var animation_player := $"../AnimatedSprite2D"

var states: Dictionary = {}


func get_initial_state() -> PlayerState:
	return starting_state if starting_state != null else get_child(0)


func _ready() -> void:
	if player == null:
		printerr(owner.name + ": No player reference set. Defaulting to the owner.")
		player = owner as CharacterBody2D

	# Give every state a reference to the state machine.
	for state_node: PlayerState in find_children("*", "res://player/scripts/player_state.gd"):
		states[state_node.state_type] = state_node
		state_node.transition.connect(_transition_to_next_state)
		state_node.init(player)

	# State machines usually access data from the root node of the scene they're part of: the owner.
	# We wait for the owner to be ready to guarantee all the data and nodes the states may need are available.
	await owner.ready

	if current_state:
		current_state.enter()
		animation_player.play(current_state.ANIMATION_NAME)


func _process(delta: float) -> void:
	if current_state == null:
		printerr(owner.name + ": No state set.")
		return
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state == null:
		printerr(owner.name + ": No state set.")
		return
	current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state == null:
		printerr(owner.name + ": No state set.")
		return
	current_state.handle_input(event)


func _transition_to_next_state(target_state: GameEnums.PlayerStateType, data: Dictionary = {}) -> void:
	var previous_state := current_state
	current_state.exit()
	current_state = states.get(target_state)
	if current_state == null:
		printerr(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state
	current_state.enter(previous_state.state_type)
	animation_player.play(current_state.ANIMATION_NAME)
