# Scene with a horizontal slider for float value settings
class_name SliderHbox extends HBoxContainer

# Emitted when slider value changes
signal value_changed(value: float)

# The text of the Label should be changed to identify the setting
@export var title : String = "" : set = set_title

# Current slider value with setter
@export var value: float = 0.0 : set = set_value

# Range parameters (exported for easy editing)
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var step: float = 1.0

@onready var label: Label = $Label
@onready var slider: HSlider = $Slider

func _ready() -> void:
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.value_changed.connect(_on_slider_value_changed)

func set_title(new_title: String) -> void:
	title = new_title
	if not label:
		await ready
	label.text = title

func set_value(new_value: float) -> void:
	value = clamp(new_value, min_value, max_value)
	if not slider:
		await ready
	if not is_equal_approx(slider.value, value): # Avoid unnecessary updates
		slider.value = value
	value_changed.emit(value)

func _on_slider_value_changed(slider_value: float) -> void:
	set_value(slider_value)
	
