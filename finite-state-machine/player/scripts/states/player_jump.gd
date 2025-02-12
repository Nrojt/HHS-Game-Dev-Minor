extends PlayerState
class_name PlayerJump

@export var JUMP_VELOCITY: float = -300.0
@export var COYOTE_TIME: float = 0.1

@onready var coyote_timer := $CoyoteTimer


# TODO fix: why can the player sometimes jump twice

func physics_update(delta):
	# Handle jump
	if Input.is_action_just_pressed("jump") and jump_available:
		jump_available = false
		player.velocity.y = JUMP_VELOCITY

	# Add the gravity.
	if not player.is_on_floor():
		if jump_available and coyote_timer.is_stopped():
			coyote_timer.start(COYOTE_TIME)
		player.velocity += player.get_gravity() * delta
	else:
		coyote_timer.stop()
		jump_available = true


func exit() -> void:
	coyote_timer.stop()


func _on_coyote_timer_timeout():
	if not player.is_on_floor():
		jump_available = false
	pass
