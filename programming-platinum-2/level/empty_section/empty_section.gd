extends Node3D

@export_group("draggables")
@export_range(0,3) var max_placed : int = 2
@export_group("movement")
@export var movement_speed : float = 0.01
@export var movement_direction : Vector3 = Vector3.BACK

@onready var area_left : DropArea = $DropAreaLeft
@onready var area_middle : DropArea = $DropAreaMiddle
@onready var area_right : DropArea = $DropAreaRight

func _ready() -> void:
	GameManager.placed_draggable.connect(_on_placed_draggable)
	

func _physics_process(delta: float) -> void:
	global_position += movement_direction * movement_speed

# Check if the max amount of draggables have been placed
func _on_placed_draggable(_placed_draggable : Draggable ) -> void:
	var placed := 0
	if !area_left.enabled: placed +=1
	if !area_middle.enabled: placed +=1
	if !area_right.enabled: placed +=1
	
	if placed >= max_placed:
		area_left.enabled = false
		area_middle.enabled = false
		area_right.enabled = false
		GameManager.placed_draggable.disconnect(_on_placed_draggable)
