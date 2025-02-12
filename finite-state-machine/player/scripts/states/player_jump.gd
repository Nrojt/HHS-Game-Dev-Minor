extends PlayerState
class_name PlayerJump

@export var JUMP_VELOCITY: float = -300.0
@export var COYOTE_TIME: float = 0.1

@onready var coyote_timer := $CoyoteTimer # Todo this will break in hirearchy 


# TODO fix: why can the player sometimes jump twice

func _physics_process(delta):
	# Handle jump
	if Input.is_action_just_pressed("jump") and jump_available:
		jump_available = false
		PLAYER.velocity.y = JUMP_VELOCITY

	# Add the gravity.
	if not PLAYER.is_on_floor():
		if jump_available and coyote_timer.is_stopped():
			coyote_timer.start(COYOTE_TIME)
		PLAYER.velocity += PLAYER.get_gravity() * delta
	else:
		coyote_timer.stop()
		jump_available = true


func _on_coyote_timer_timeout():
	if not PLAYER.is_on_floor():
		jump_available = false
	pass
