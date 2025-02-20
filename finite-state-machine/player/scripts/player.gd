extends CharacterBody2D

@onready var state_machine := $PlayerStateMachine
@onready var animated_sprite := $AnimatedSprite2D


func _process(_delta: float) -> void:
	# flipping the sprite
	animated_sprite.flip_h = velocity.x < 0


func _physics_process(_delta):
	move_and_slide()

	

	
