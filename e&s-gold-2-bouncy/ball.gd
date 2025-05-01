extends CharacterBody2D
class_name Ball

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var trail: Line2D = $Trail

@export_group("ball")
@export var is_ball_one := false
@export var colour_ball_one := Color('#D8D8F6')
@export var colour_ball_two := Color('#B18FCF')
@export var speed := 75.0
@export_group("trail")
@export var trail_max_points := 10
@export var trail_min_distance := 2.0

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
	
	# Creating gradient for the trail
	trail.clear_points()
	trail.default_color = colour
	var grad := Gradient.new()
	grad.set_color(1, Color(colour.r, colour.g, colour.b, 0.8))
	grad.set_color(0, Color(colour.r, colour.g, colour.b, 0.1))
	trail.gradient = grad

func _physics_process(delta: float) -> void:
	# Creating the trail points
	var move_delta: Vector2 = position - _last_trail_pos
	if move_delta.length() > trail_min_distance:
		# Add the negative of the ball's movement to the trail
		for i in range(trail.points.size()):
			trail.set_point_position(i, trail.get_point_position(i) - move_delta)
		# Adding current ball location
		trail.add_point(Vector2.ZERO)
		_last_trail_pos = position
	if trail.points.size() > trail_max_points:
		trail.remove_point(0)

	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	# If there is a collision, bounce the ball and toggle the collided tile
	if collision:
		# Bounce the velocity to the ball collides
		velocity = velocity.bounce(collision.get_normal())

		# If the collision is with a tile, toggle it
		if collision.get_collider() is Tile:
			collision.get_collider().toggle(self)


func _get_collision_layer() -> int:
	return collision_layer
