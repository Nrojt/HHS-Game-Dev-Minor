class_name DropArea extends Area3D

@onready var visualization : MeshInstance3D = $Visualization

var hover_draggable : Draggable
var enabled := true

func _input(event: InputEvent) -> void:
	if event.is_action_released("hold_draggable") && hover_draggable:
		print("holding released")
		hover_draggable = null
		enabled = false
		GameManager.placed_draggable.emit(GameManager.current_draggable)
		visualization.hide()

func _mouse_enter() -> void:
	if enabled:
		if Input.is_action_pressed("hold_draggable") && GameManager.current_draggable:
			visualization.show()
			hover_draggable = GameManager.current_draggable.duplicate()
			GameManager.current_draggable.hide()
			hover_draggable.placed = true
			add_child(hover_draggable)
			hover_draggable.position = Vector3.ZERO
	
func _mouse_exit() -> void:
	if enabled:
		visualization.hide()
		GameManager.current_draggable.show()
		if hover_draggable:
			remove_child(hover_draggable)
			hover_draggable = null
