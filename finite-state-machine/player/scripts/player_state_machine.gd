extends Node

@export var starting_state: PlayerState

@onready
var current_state: PlayerState = get_initial_state()
@onready var player := $".." #Todo passing in player directly kinda bad

var states: Dictionary = {}


func get_initial_state() -> PlayerState:
	return starting_state if starting_state != null else get_child( 0)


func _ready() -> void:
	# Give every state a reference to the state machine.
	for state_node: PlayerState in find_children("*", "res://player/scripts/player_state.gd"):
		states[state_node.name.to_lower()] = state_node
		state_node.transition.connect(_transition_to_next_state)
		state_node.init(player)

	print(states)

	# State machines usually access data from the root node of the scene they're part of: the owner.
	# We wait for the owner to be ready to guarantee all the data and nodes the states may need are available.
	await owner.ready

	if current_state:
		current_state.enter("")


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


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := current_state.name
	current_state.exit()
	current_state = get_node(target_state_path.to_lower())
	current_state.enter(previous_state_path, data)
