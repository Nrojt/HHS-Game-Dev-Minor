extends Node
@export var starting_state: CameraState
@export var camera_transformer: RemoteTransform3D

@onready
var current_state: CameraState = get_initial_state()

var states: Dictionary = {}


func get_initial_state() -> CameraState:
	return starting_state if starting_state != null else get_child(0)

func _input(event: InputEvent) -> void:
	if current_state == null:
		printerr(owner.name + ": No state set.")
		return
	current_state.handle_input(event)

func _ready() -> void:
	if camera_transformer == null:
		push_error(owner.name + ": No camera transformer reference set")

	# Get all states in the scene tree
	for state_node: CameraState in find_children("*", "res://player/camera_state.gd"):
		states[state_node.STATE_TYPE] = state_node
		state_node.transition.connect(_transition_to_next_state) # connecting all the transitions to the state machine
		state_node.init(camera_transformer)

	# We wait for the owner to be ready to guarantee all the data and nodes are available.
	await owner.ready

	print(states)

	if current_state:
		current_state.enter()


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


func _transition_to_next_state(target_state: CreatedEnums.CameraStateType) -> void:
	var previous_state := current_state
	current_state.exit()
	current_state = states.get(target_state)
	if current_state == null:
		printerr(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state
	current_state.enter()
