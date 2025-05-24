class_name EffectCamera
extends Camera2D

signal trigger_trauma(amount: float)
signal trigger_zoom(duration: float, target: Node2D)
signal trigger_flash(color: Color, duration: float)
signal trigger_drift(strength: float, duration: float)
signal trigger_elastic_zoom(target_scale: float, duration: float)

@export_group("Screen Shake")
@export var decay: float = 1.5
@export var max_offset: Vector2 = Vector2(32, 24)
@export var max_roll: float = 0.05
@export var trauma_power: float = 1.5
@export var noise_frequency: float = 5.0

@export_group("Zoom Effect")
@export var target_zoom_level: float = 2.0
@export var zoom_speed: float = 2.2

@export_group("Screen Flash")
@export var flash_layer: int = 10

@export_group("Recoil")
@export var recoil_decay: float = 3.0

@export_group("Drift")
@export var drift_frequency: float = 0.5

@export_group("Pulse")
@export var pulse_base_zoom: float = 1.0

var trauma: float = 0.0
var _noise := FastNoiseLite.new()
var _noise_seed: float = 0.0
var _target_zoom: Vector2 = Vector2.ONE

var _zoom_in_tween: Tween
var _zoom_out_tween: Tween
var _original_zoom: Vector2
var _original_position: Vector2

var _flash_rect: ColorRect
var _recoil_offset: Vector2 = Vector2.ZERO
var _drift_time: float = 0.0
var _drift_strength: float = 0.0
var _pulse_time: float = 0.0
var _pulse_intensity: float = 0.0
var _pulse_frequency: float = 0.0
var _pulse_duration: float = 0.0
var _base_zoom: Vector2
var _elastic_tween: Tween


func _ready() -> void:
	trigger_trauma.connect(_add_trauma)
	trigger_zoom.connect(_zoom_effect)
	trigger_flash.connect(_flash_effect)
	trigger_drift.connect(_drift_effect)
	trigger_elastic_zoom.connect(_elastic_zoom_effect)
	
	_target_zoom = Vector2.ONE
	_original_zoom = zoom
	_original_position = global_position
	_base_zoom = zoom
	
	_noise.seed = randi()
	_noise.frequency = noise_frequency
	
	_setup_flash_overlay()


func _process(delta: float) -> void:
	var total_offset: Vector2 = Vector2.ZERO
	
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		total_offset += _calculate_shake()
	
	if _recoil_offset.length() > 0.1:
		_recoil_offset = _recoil_offset.move_toward(Vector2.ZERO, recoil_decay * delta * 100)
		total_offset += _recoil_offset
	
	if _drift_strength > 0.0:
		_drift_time += delta
		var drift_x: float = sin(_drift_time * drift_frequency) * _drift_strength
		var drift_y: float = cos(_drift_time * drift_frequency * 1.3) * _drift_strength * 0.7
		total_offset += Vector2(drift_x, drift_y)
	
	if _pulse_duration > 0.0:
		_pulse_time += delta
		_pulse_duration -= delta
		var pulse_factor: float = sin(_pulse_time * _pulse_frequency * TAU) * _pulse_intensity
		zoom = _base_zoom + Vector2(pulse_factor, pulse_factor)
		
		if _pulse_duration <= 0.0:
			zoom = _base_zoom
	
	offset = total_offset
	
	if trauma <= 0.0 and _recoil_offset.length() <= 0.1:
		if _pulse_duration <= 0.0:
			rotation = 0.0


func _calculate_shake() -> Vector2:
	var amount: float = pow(trauma, trauma_power)
	_noise_seed += get_process_delta_time()
	var shake_x = _noise.get_noise_1d(_noise_seed) * max_offset.x * amount
	var shake_y = _noise.get_noise_1d(_noise_seed + 100) * max_offset.y * amount
	var shake_rotation = _noise.get_noise_1d(_noise_seed + 200) * max_roll * amount
	rotation = shake_rotation
	return Vector2(shake_x, shake_y)


func _setup_flash_overlay() -> void:
	_flash_rect = ColorRect.new()
	_flash_rect.color = Color.TRANSPARENT
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.z_index = flash_layer
	get_viewport().call_deferred("add_child", _flash_rect)
	
	var update_flash_size = func():
		if _flash_rect and is_instance_valid(_flash_rect) and _flash_rect.get_parent():
			_flash_rect.size = get_viewport().get_visible_rect().size
			_flash_rect.position = Vector2.ZERO
	
	# Defer this connection as well, or call it after _flash_rect is added
	call_deferred("connect_flash_size_updater", update_flash_size)


func connect_flash_size_updater(callable_func: Callable) -> void:
	callable_func.call() # Initial call
	if get_viewport():
		get_viewport().size_changed.connect(callable_func)


func _zoom_effect(duration: float, target: Node2D) -> void:
	if _zoom_in_tween != null and _zoom_in_tween.is_valid():
		_zoom_in_tween.kill()
	if _zoom_out_tween != null and _zoom_out_tween.is_valid():
		_zoom_out_tween.kill()
		
	var target_zoom_vector: Vector2 = Vector2(target_zoom_level, target_zoom_level)
	var target_position: Vector2 = target.global_position
	
	var is_already_zoomed: bool = zoom.x > _original_zoom.x * 1.01
	
	_zoom_in_tween = create_tween()
	_zoom_in_tween.set_parallel(true)
	_zoom_in_tween.tween_property(self, "zoom", target_zoom_vector, duration)
	_zoom_in_tween.tween_property(self, "global_position", target_position, duration)

	var zoom_out_delay: float = duration if not is_already_zoomed else 0.0
	
	_zoom_out_tween = create_tween()
	_zoom_out_tween.tween_property(self, "zoom", _original_zoom, duration).set_delay(duration + zoom_out_delay)
	_zoom_out_tween.tween_property(self, "global_position", _original_position, duration).set_delay(duration + zoom_out_delay)


func _flash_effect(color: Color, duration: float) -> void:
	if not _flash_rect or not is_instance_valid(_flash_rect):
		return
		
	_flash_rect.color = color
	var tween: Tween = create_tween()
	tween.tween_property(_flash_rect, "color:a", 0.0, duration)


func _drift_effect(strength: float, duration: float) -> void:
	_drift_strength = strength
	
	var tween: Tween = create_tween()
	tween.tween_method(func(value: float): _drift_strength = value, strength, 0.0, duration)


func _elastic_zoom_effect(target_scale: float, duration: float) -> void:
	if _elastic_tween and _elastic_tween.is_valid():
		_elastic_tween.kill()
	
	var target_zoom_vec: Vector2 = Vector2(target_scale, target_scale)
	
	_elastic_tween = create_tween()
	_elastic_tween.tween_property(self, "zoom", target_zoom_vec, duration * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_elastic_tween.tween_property(self, "zoom", _original_zoom, duration * 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)


func _exit_tree() -> void:
	if _flash_rect and is_instance_valid(_flash_rect):
		_flash_rect.queue_free()
