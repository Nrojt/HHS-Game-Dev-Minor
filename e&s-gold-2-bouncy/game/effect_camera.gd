class_name EffectCamera
extends Camera2D

signal trigger_trauma(amount: float)
@export_group("Screen Shake")
@export var decay: float = 1.5
@export var max_offset: Vector2 = Vector2(32, 24)
@export var max_roll: float = 0.05
@export var trauma_power: float = 1.5
## Jitter speed of the noise
@export var noise_frequency: float = 5.0

var trauma: float      =  0.0
var _noise             := FastNoiseLite.new()
var _noise_seed: float =  0.0


func _ready() -> void:
	trigger_trauma.connect(add_trauma)
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
	var amount: float = pow(trauma, trauma_power)
	_noise_seed += delta
	# Using +100 and +200 for some variation, magic numbers but kind of unnecesarry to turn into export vars
	var shake_x        = _noise.get_noise_1d(_noise_seed) * max_offset.x * amount
	var shake_y        = _noise.get_noise_1d(_noise_seed + 100) * max_offset.y * amount
	var shake_rotation = _noise.get_noise_1d(_noise_seed + 200) * max_roll * amount
	offset = Vector2(shake_x, shake_y)
	rotation = shake_rotation


func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)
