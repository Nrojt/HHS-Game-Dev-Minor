extends PanelContainer
@export var label_path : Label
@export var button_path : Button


func _ready():
	button_path.pressed.connect(_on_input_button_pressed)
	
func _on_input_button_pressed() -> void:
	if GameManager.is_remapping:
		print("Already remapping a different key")
		return
	
	GameManager.is_remapping = true
	label_path.text = "Press key to bind..."
