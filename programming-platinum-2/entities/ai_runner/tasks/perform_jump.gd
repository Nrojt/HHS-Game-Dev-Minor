class_name PerformJump
extends BTAction

@export var nearest_object_var_name: StringName = "nearest_object_distance"
@export var nearest_object_jump_start_distance: float = 3.0
@export var jump_after_obstacle_distance: float = 0.3

var jumping := false
var jump_target_z := 0.0
var jump_horizontal_speed : float

func _setup() -> void:
	jump_horizontal_speed = GameManager.movement_speed
	jumping = false
	jump_target_z = 0.0

func _tick(_delta: float) -> Status:
	var ai: AiRunner = agent as AiRunner
	if not ai:
		return FAILURE

	var closest = blackboard.get_var(nearest_object_var_name, null)
	if closest == null or not closest.has("node"):
		return FAILURE

	var node = closest.node
	if not node or not node.has_method("get_global_position"):
		return FAILURE

	var ai_pos: Vector3 = ai.global_position
	var closest_pos: Vector3 = node.global_position
	var distance: float = ai_pos.distance_to(closest_pos)

	# If not started jumping, check if we should start
	if not jumping:
		if distance > nearest_object_jump_start_distance:
			return RUNNING
		if ai.is_on_floor():
			ai.velocity.y = ai.jump_velocity
			jumping = true
			jump_target_z = closest_pos.z + jump_after_obstacle_distance
			# Always jump forward
			ai.velocity.z = jump_horizontal_speed
			return RUNNING
		else:
			# Not on floor, can't jump, do nothing
			return RUNNING

	# If already jumping, keep moving towards the jump target
	if jumping:
		# Only set horizontal velocity if in the air
		if not ai.is_on_floor():
			# Keep moving forward while in the air
			ai.velocity.z = jump_horizontal_speed
		# Consider "cleared" if AI's z is ahead of the target and is on the floor
		if ai.global_position.z > jump_target_z and ai.is_on_floor():
			jumping = false
			ai.velocity.z = 0.0 # Stop horizontal movement after landing
			return SUCCESS
		return RUNNING

	return FAILURE
