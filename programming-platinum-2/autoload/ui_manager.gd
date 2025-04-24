extends CanvasLayer

var hud_scene : PackedScene = preload("uid://c8p4y13l4wjft")

func _ready():
	add_child(hud_scene.instantiate())
