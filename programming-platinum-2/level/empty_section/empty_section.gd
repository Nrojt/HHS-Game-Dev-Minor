class_name EmptySection extends Node3D


@export_group("draggables")
@export_range(0, 3) var max_placed: int = 2

@export_group("movement")
@export var movement_direction: Vector3 = Vector3.BACK

@onready var drop_areas: Array[DropArea] = [
	$DropAreaLeft,
	$DropAreaMiddle,
	$DropAreaRight
]

@onready var end_marker : Marker3D = $Marker3D

func _ready() -> void:
	GameManager.placed_draggable.connect(_on_placed_draggable)

func _physics_process(delta: float) -> void:
	global_position += movement_direction * GameManager.movement_speed * delta

func _on_placed_draggable(_placed_draggable: Draggable) -> void:
	
	var placed := 0
	for area in drop_areas:
		if not area.enabled:
			placed += 1

	if placed >= max_placed:
		for area in drop_areas:
			area.enabled = false
		GameManager.placed_draggable.disconnect(_on_placed_draggable)
