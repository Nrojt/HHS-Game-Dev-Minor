extends Control

@onready var height_label := $HeightLabel
@onready var game_over_screen := $GameOver
@onready var score_label := %ScoreLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over_screen.visible = false
	SignalManager.player_death.connect(_on_player_death)
	SignalManager.add_child_scene.emit("uid://b2tjtn7p8hl0u")


func _on_player_death() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	score_label.text = height_label.text
	height_label.visible = false
	game_over_screen.visible = true
