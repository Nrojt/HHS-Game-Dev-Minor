extends CharacterBody2D
class_name Ball

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var trail: Line2D = $Trail
@onready var hit_particles : CPUParticles2D = $HitParticles

@export_group("ball")
@export var is_ball_one := false
@export var colour_ball_one := Color('#D8D8F6')
@export var colour_ball_two := Color('#B18FCF')
@export var speed := 75.0
@export_group("trail")
@export var trail_max_points := 10
@export var trail_min_distance := 2.0
@export_group("particles")
@export_range(0.1, 1.0) var bounce_particle_emit_duration : float = 0.2
@export_range(0.1, 1.0) var min_velocity_multiplier  : float = 0.8
@export_range(1.0, 2.0) var max_velocity_multiplier  : float = 1.2
@export_group("camera")
@export var effect_camera : EffectCamera
@export_range(0.1, 1.0) var tile_collision_trauma : float = 0.2

var _last_trail_pos: Vector2

func _ready() -> void:
	# Set the position
	global_position.y = (get_viewport_rect().size.y/2)
	if is_ball_one:
		global_position.x = (get_viewport_rect().size.x / 4) + (get_viewport_rect().size.y / 2)
	else:
		global_position.x = (get_viewport_rect().size.x / 4)

	# Set velocity
	velocity.x = -speed
	velocity.y = randi_range(-15, 15) # randomize that starting velocity a bit.

	# Set the correct colour
	var colour: Color = colour_ball_one if is_ball_one else colour_ball_two
	polygon_2d.color = colour
	hit_particles.color = colour
	
	# Creating gradient for the trail
	trail.clear_points()
	trail.default_color = colour
	var grad := Gradient.new()
	grad.set_color(1, Color(colour.r, colour.g, colour.b, 0.8))
	grad.set_color(0, Color(colour.r, colour.g, colour.b, 0.1))
	trail.gradient = grad
	
	# Setting up the particles
	hit_particles.one_shot = true
	hit_particles.emitting = false
	hit_particles.lifetime = bounce_particle_emit_duration

func _physics_process(delta: float) -> void:
	_move_trail()

	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	# If there is a collision, bounce the ball and toggle the collided tile
	if collision:
		var old_velocity = velocity
		_collision_effect(old_velocity)
		
		# Bounce the velocity to the ball collides
		velocity = velocity.bounce(collision.get_normal())

		# If the collision is with a tile, toggle it
		if collision.get_collider() is Tile:
			if effect_camera:
				effect_camera.add_trauma(tile_collision_trauma)
			collision.get_collider().toggle(self)

func _move_trail() -> void:
	# Creating the trail points
	var move_delta: Vector2 = position - _last_trail_pos
	if move_delta.length() > trail_min_distance:
		# Add the negative of the ball's movement to the trail
		for i in range(trail.points.size()):
			trail.set_point_position(i, trail.get_point_position(i) - move_delta)
		# Adding current ball location
		trail.add_point(Vector2.ZERO)
		_last_trail_pos = position
	
	# Remove end points from trail
	if trail.points.size() > trail_max_points  || move_delta == Vector2.ZERO:
		trail.remove_point(0)
		
func _collision_effect(old_velocity: Vector2) -> void:
	var delta_v = (velocity.bounce(Vector2.UP) - old_velocity).length()
	hit_particles.initial_velocity_min = delta_v * min_velocity_multiplier
	hit_particles.initial_velocity_max = delta_v * max_velocity_multiplier
	hit_particles.angular_velocity_max = delta_v
	
	hit_particles.emitting = true

func _get_collision_layer() -> int:
	return collision_layer
