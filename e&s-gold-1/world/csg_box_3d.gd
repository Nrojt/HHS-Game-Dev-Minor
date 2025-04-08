extends CSGBox3D

@export var min_interval : float = 1.0
@export var max_interval : float = 2.0
@export_range(0.01, 1.0, 0.01) var flash_duration : float = 0.1

@onready var interval_timer : Timer = $IntervalTimer
@onready var duration_timer : Timer = $DurationTimer

func _on_timer_timeout() -> void:
	# generating a random colour
	var r : float = lerp(0.0, 1.0, randf())
	var g : float = lerp(0.0, 1.0, randf())
	var b : float = lerp(0.0, 1.0, randf())
	var random_colour : Color = Color(r, g, b)
	material.set_shader_parameter("flash_colour", random_colour)
	material.set_shader_parameter("flash", true)
	
	# Starting the timer
	var random_interval : float = randf_range(min_interval, max_interval)
	duration_timer.start(flash_duration)
	interval_timer.start(random_interval + flash_duration)


func _on_duration_timer_timeout() -> void:
	material.set_shader_parameter("flash", false)
