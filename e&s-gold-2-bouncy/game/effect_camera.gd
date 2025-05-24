class_name EffectCamera
extends Camera2D

signal trigger_trauma(amount: float)
signal trigger_zoom(duration: float, target: Node2D)
@export_group("Screen Shake")
@export var decay: float = 1.5
@export var max_offset: Vector2 = Vector2(32, 24)
@export var max_roll: float = 0.05
@export var trauma_power: float = 1.5
@export var noise_frequency: float = 5.0
@export_group("Zoom Effect")
@export var target_zoom_level: float = 2.0
@export var zoom_speed: float = 2.2

var trauma: float         =  0.0
var _noise                := FastNoiseLite.new()
var _noise_seed: float    =  0.0
var _target_zoom: Vector2 =  Vector2.ONE

var _zoom_in_tween: Tween
var _zoom_out_tween: Tween
var _original_zoom: Vector2
var _original_position: Vector2


func _ready() -> void:
	trigger_trauma.connect(add_trauma)
	trigger_zoom.connect(_zoom_effect)
	_target_zoom = Vector2.ONE
	_original_zoom = zoom
	_original_position = global_position
	_noise.seed = randi()
	_noise.frequency = noise_frequency


func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		_shake(delta)
	else:
		offset = Vector2.ZERO
		rotation = 0.0


func _shake(delta: float) -> void:
	var amount: float  = pow(trauma, trauma_power)
	_noise_seed += delta
	var shake_x        = _noise.get_noise_1d(_noise_seed) * max_offset.x * amount
	var shake_y        = _noise.get_noise_1d(_noise_seed + 100) * max_offset.y * amount
	var shake_rotation = _noise.get_noise_1d(_noise_seed + 200) * max_roll * amount
	offset = Vector2(shake_x, shake_y)
	rotation = shake_rotation


func _zoom_effect(duration: float, target: Node2D) -> void:
	if _zoom_in_tween != null and _zoom_in_tween.is_valid():
		_zoom_in_tween.kill()
	if _zoom_out_tween != null and _zoom_out_tween.is_valid():
		_zoom_out_tween.kill()
		
	var target_zoom_vector: Vector2 = Vector2(target_zoom_level, target_zoom_level)
	var target_position: Vector2    = target.global_position
	
	var is_already_zoomed: bool = zoom.x > _original_zoom.x * 1.01
	
	_zoom_in_tween = create_tween()
	_zoom_in_tween.set_parallel(true)
	_zoom_in_tween.tween_property(self, "zoom", target_zoom_vector, duration)
	_zoom_in_tween.tween_property(self, "global_position", target_position, duration)

	var zoom_out_delay: float = duration if not is_already_zoomed else 0.0
	
	_zoom_out_tween = create_tween()
	_zoom_out_tween.tween_property(self, "zoom", _original_zoom, duration).set_delay(duration + zoom_out_delay)
	_zoom_out_tween.tween_property(self, "global_position", _original_position, duration).set_delay(duration + zoom_out_delay)


func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)
