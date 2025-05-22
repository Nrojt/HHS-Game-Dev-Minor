extends Node3D

var _current_drag_card : DraggableCard

func _ready():
	GameManager.placed_draggable.connect(_placed_draggable)
	GameManager.end_dragging_draggable.connect(_remove_draggable)
	GameManager.start_dragging_draggable.connect(_spawn_draggable)

func _spawn_draggable(drag_card : DraggableCard, draggable : DraggableBase) -> void:
	if drag_card: _current_drag_card = drag_card
	if draggable:
		print("Draggable: " + draggable.name)
		GameManager.current_draggable = draggable
		print(GameManager.current_draggable)
		add_child(draggable)
		draggable.show()

func _remove_draggable(draggable: DraggableBase) -> void:
	if is_instance_valid(draggable):
		if _current_drag_card: _current_drag_card.show_blur = false
		GameManager.current_draggable = null
		if draggable.is_inside_tree() and draggable.get_parent() == self:
			remove_child(draggable)


func _placed_draggable(placed_draggable : DraggableBase) -> void:
	if _current_drag_card: _current_drag_card.play_exit_animation()
	_remove_draggable(placed_draggable)
