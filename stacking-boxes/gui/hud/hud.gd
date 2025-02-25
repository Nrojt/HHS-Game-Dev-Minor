extends Control

@onready var height_label := $HeightLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.player_death.connect(_on_player_death)

func _on_player_death() -> void:
	queue_free()
