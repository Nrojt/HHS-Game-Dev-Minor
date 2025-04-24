class_name DropArea extends Area3D

@export_range(0.0, 3.0, 1.0) var lane_index := 1
@export_flags_3d_physics var placed_draggable_collision_layer: int = 1

@onready var visualization : MeshInstance3D = $Visualization

var hover_draggable : Draggable
var enabled := true

func _input(event: InputEvent) -> void:
	if event.is_action_released("hold_draggable") && hover_draggable:
		print("holding released")
		var placed_draggable := hover_draggable
		hover_draggable = null
		enabled = false
		placed_draggable.placed = true
		placed_draggable.lane_index = lane_index
		placed_draggable.set_collision_layer(placed_draggable_collision_layer)
		placed_draggable.add_to_group("Obstacles")
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
