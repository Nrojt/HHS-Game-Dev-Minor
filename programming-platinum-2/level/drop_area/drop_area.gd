extends Area3D

# TODO: after placing draggable, the other dropareas dont function anymore? dropping doesnt work for them

@onready var visualization : MeshInstance3D = $Visualization

var hover_draggable : Draggable
var placed_draggable : Draggable

func _input(event: InputEvent) -> void:
	if event.is_action_released("hold_draggable") && hover_draggable:
		print("holding released")
		placed_draggable = hover_draggable
		hover_draggable = null
		GameManager.current_draggable = null
		visualization.hide()

func _mouse_enter() -> void:
	if !placed_draggable:
		visualization.show()
		if Input.is_action_pressed("hold_draggable") && GameManager.current_draggable:
			hover_draggable = GameManager.current_draggable.duplicate()
			hover_draggable.placed = true
			add_child(hover_draggable)
			hover_draggable.position = Vector3.ZERO
	
func _mouse_exit() -> void:
	if !placed_draggable:
		visualization.hide()
		if hover_draggable:
			remove_child(hover_draggable)
			hover_draggable = null
