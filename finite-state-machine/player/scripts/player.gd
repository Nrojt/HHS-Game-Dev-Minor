extends CharacterBody2D

@export var SPEED: float = 100.0
@export var JUMP_VELOCITY: float = -300.0
@export var COYOTE_TIME: float = 0.1
@export var MAX_JUMPS: int = 2

@onready var coyote_timer := $CoyoteTimer

var jumps_available: int = MAX_JUMPS


func _physics_process(delta):
	# Handle jump
	if Input.is_action_just_pressed("jump") and jumps_available > 0:
		jumps_available -= 1
		velocity.y = JUMP_VELOCITY

	# Add the gravity.
	if not is_on_floor():
		if jumps_available > 0 and coyote_timer.is_stopped():
			coyote_timer.start(COYOTE_TIME)
		velocity += get_gravity() * delta
	else:
		coyote_timer.stop()
		jumps_available = MAX_JUMPS

	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_coyote_timer_timeout():
	if not is_on_floor() and jumps_available > 0:
		jumps_available -= 1
