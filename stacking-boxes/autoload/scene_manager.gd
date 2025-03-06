extends Node

func _ready() -> void:
	SignalManager.player_death.connect(_on_player_death)


func go_to_main_menu() -> void:
	GameManager.reset_variables()
	SignalManager.add_child_scene.emit("uid://cb33156u20b8o", true)
	SignalManager.add_child_scene.emit("uid://dlnvdqqw7kash", false)


func go_to_game() -> void:
	print("going to game")
	GameManager.reset_variables()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalManager.add_child_scene.emit("uid://b14icr4kflsvi", true)
	SignalManager.add_child_scene.emit("uid://cc7esd6v5t8g2", false)
	SignalManager.add_child_scene.emit("uid://b2tjtn7p8hl0u", false)


func _on_player_death() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	SignalManager.add_child_scene.emit("uid://cvoiws1lo4t50", false)
