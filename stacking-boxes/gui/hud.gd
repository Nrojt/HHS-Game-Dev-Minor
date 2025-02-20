extends Control

@onready var height_label := $HeightLabel
@onready var game_over_screen := $GameOver
@onready var score_label := %ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over_screen.visible = false
	SignalManager.player_death.connect(_on_player_death)
	print("Loading in gameplay")
	SignalManager.load_scene_as_child.emit(get_tree().get_current_scene(), "res://levels/gameplay_main.tscn")

func _on_player_death() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	score_label.text = height_label.text
	height_label.visible = false
	game_over_screen.visible = true
