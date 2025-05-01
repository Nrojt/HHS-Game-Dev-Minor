extends StaticBody2D
class_name Tile

@onready var polygon_2d: Polygon2D = $Polygon2D

@export var ball: Ball
@export_group("Scale Time")
@export var hit_scale: float = 1.15
@export var scale_up_time: float = 0.2
@export var scale_down_time: float = 0.18
@export var min_rotation_angle: float = -0.15
@export var max_rotation_angle: float = 0.15

# To keep track of the tween
var _hit_tween: Tween
var _original_scale: Vector2
var _original_rotation: float


func _ready() -> void:
	_original_scale = polygon_2d.scale
	_original_rotation = polygon_2d.rotation
	set_color()


func toggle(collided_ball: Ball) -> void:
	ball = collided_ball

	# Set collision layer to layer that the collided ball is on.
	collision_layer = ball._get_collision_layer()

	# hit effecct
	create_hit_effect()

	# Switch colour
	set_color()


func create_hit_effect() -> void:
	# If a previous hit effect tween is still running, kill it.
	if _hit_tween != null and _hit_tween.is_valid():
		_hit_tween.kill()
		polygon_2d.scale = _original_scale
		polygon_2d.rotation = _original_rotation

	_hit_tween = polygon_2d.create_tween()
	var enlarged_scale: Vector2 = _original_scale * hit_scale
	var random_angle: float     = randf_range(min_rotation_angle, max_rotation_angle)

	_hit_tween.tween_property(polygon_2d, "scale", enlarged_scale, scale_up_time)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_hit_tween.parallel().tween_property(polygon_2d, "rotation", _original_rotation + random_angle, scale_up_time)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	_hit_tween.tween_property(polygon_2d, "scale", _original_scale, scale_down_time)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_hit_tween.parallel().tween_property(polygon_2d, "rotation", _original_rotation, scale_down_time)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func set_color() -> void:
	# Set the colour to the opposite ball's colour
	if ball.is_ball_one:
		polygon_2d.color = ball.colour_ball_two
	else:
		polygon_2d.color = ball.colour_ball_one
