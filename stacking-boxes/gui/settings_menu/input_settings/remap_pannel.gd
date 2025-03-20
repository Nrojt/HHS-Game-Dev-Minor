class_name RemapPanel extends PanelContainer
@export var label_path: Label
@export var button_path: Button
@export var input_type: CreatedEnums.InputType

var action_to_remap: String


func _ready():
	button_path.pressed.connect(_on_input_button_pressed)


func _on_input_button_pressed() -> void:
	if SaveManager.is_remapping:
		print("Already remapping a different key")
		return

	SaveManager.action_to_remap = action_to_remap
	SaveManager.input_type = input_type
	SaveManager.is_remapping = true
	label_path.text = "Press key to bind..."
