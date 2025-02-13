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

	# Get all states in the scene tree
	for state_node: PlayerState in find_children("*", "res://player/scripts/player_state.gd"):
		states[state_node.STATE_TYPE] = state_node
		state_node.transition.connect(_transition_to_next_state) # connecting all the transitions to the state machine
		state_node.init(player)

	# We wait for the owner to be ready to guarantee all the data and nodes are available.
	await owner.ready

	print(states)

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


func _transition_to_next_state(target_state: StateEnums.PlayerStateType) -> void:
	var previous_state := current_state
	current_state.exit()
	current_state = states.get(target_state)
	if current_state == null:
		printerr(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state
	current_state.enter(previous_state.STATE_TYPE)
	animation_player.play(current_state.ANIMATION_NAME)
