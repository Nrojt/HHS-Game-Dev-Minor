extends CanvasLayer

@onready var shader: ColorRect = $ColorRect

func _ready():
	shader.visible = true

func _input(event):
	if event.is_action_pressed("toggle_shader"):
		shader.visible = !shader.visible
