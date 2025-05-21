class_name EmptySection extends Node3D

@export_group("draggables")
@export_range(0, 3) var max_placed: int = 2

@export_group("movement")
@export var movement_direction: Vector3 = Vector3.BACK # (0,0,1)

@onready var drop_areas: Array[DropArea] = [
	$DropAreaLeft,
	$DropAreaMiddle,
	$DropAreaRight
]
@onready var end_marker: Marker3D = $Marker3D

var ai_restricted_by_spawner: bool = false


func _ready() -> void:
	movement_direction = movement_direction.normalized()
	if GameManager.placed_draggable.is_connected(_on_placed_draggable):
		pass
	else:
		GameManager.placed_draggable.connect(_on_placed_draggable)

	for area in drop_areas:
		area.reset_for_game_start()


func _physics_process(delta: float) -> void:
	if GameManager.game_active:
		global_position += movement_direction * GameManager.movement_speed * delta


func _on_placed_draggable(_placed_draggable: DraggableBase) -> void:
	var placed_count := 0
	for area in drop_areas:
		if not area.is_available_for_placement:
			placed_count += 1

	if placed_count >= max_placed:
		for area in drop_areas:
			if area.is_available_for_placement:
				area.set_available_for_placement(false)
		if GameManager.placed_draggable.is_connected(_on_placed_draggable):
			GameManager.placed_draggable.disconnect(_on_placed_draggable)


func set_ai_restricted_by_spawner(is_restricted: bool) -> void:
	if ai_restricted_by_spawner == is_restricted:
		return
	ai_restricted_by_spawner = is_restricted
	for area in drop_areas:
		area.set_parent_section_ai_restricted(ai_restricted_by_spawner)
