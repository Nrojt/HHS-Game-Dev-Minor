extends Control

@onready var height_label := $HeightLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.player_death.connect(_on_player_death)
	SignalManager.add_child_scene.emit("uid://cc7esd6v5t8g2", false)
	SignalManager.add_child_scene.emit("uid://b2tjtn7p8hl0u", false)


func _on_player_death() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	height_label.visible = false
	SignalManager.add_child_scene.emit("uid://cvoiws1lo4t50", false)
