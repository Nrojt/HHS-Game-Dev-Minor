class_name DropArea
extends Area3D

static var current_hovered: DropArea = null
static var all_drop_areas: Array[DropArea] = []

@export_group("Draggables")
@export_range(0.0, 3.0, 1.0) var lane_index := 1
@export_flags_3d_physics var placed_draggable_collision_layer: int = 1

@export_group("Visualization")
@export var base_visualization_color_hover: Color = Color("#7420c528")
@export var line_visualization_color_hover: Color = Color("#ef8ab137")
@export var base_visualization_color_available: Color = Color("#8BDF3A28")
@export var line_visualization_color_available: Color = Color("#10754E37")

@onready var visualization: MeshInstance3D = $Visualization
@onready var place_sound_player: AudioStreamPlayer3D = $PlaceSoundPlayer

var hover_draggable: DraggableBase
var placed_draggable_item: DraggableBase

var is_available_for_placement: bool = true
var ai_runner_physically_occupying: bool = false
var parent_section_ai_restricted: bool = false

var check_for_release := false

func _ready():
	all_drop_areas.append(self)

	var mat: Material = visualization.get_active_material(0)
	if mat:
		visualization.set_surface_override_material(0, mat.duplicate())

	GameManager.game_ended.connect(_on_game_ended)
	GameManager.game_started.connect(reset_for_game_start)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# These signals must be connected in the editor or here:
	mouse_entered.connect(_on_mouse_entered_area_signal)
	mouse_exited.connect(_on_mouse_exited_area_signal)

	reset_for_game_start()

func _exit_tree():
	all_drop_areas.erase(self)

func reset_for_game_start() -> void:
	is_available_for_placement = true
	ai_runner_physically_occupying = false
	if placed_draggable_item:
		placed_draggable_item.queue_free()
		placed_draggable_item = null
	if hover_draggable:
		hover_draggable.queue_free()
		hover_draggable = null
	_update_visualization()

func _on_game_ended() -> void:
	if placed_draggable_item:
		placed_draggable_item.queue_free()
		placed_draggable_item = null
	if hover_draggable:
		hover_draggable.queue_free()
		hover_draggable = null
	_update_visualization()

func is_effectively_enabled() -> bool:
	return (
		GameManager.game_active
		and is_available_for_placement
		and not ai_runner_physically_occupying
		and not parent_section_ai_restricted
	)

func _update_visualization() -> void:
	if is_effectively_enabled():
		if self == current_hovered and Input.is_action_pressed("hold_draggable"):
			_set_visualization_colors(
				base_visualization_color_hover, line_visualization_color_hover
			)
		else:
			_set_visualization_colors(
				base_visualization_color_available,
				line_visualization_color_available
			)
		visualization.show()
	else:
		visualization.hide()
		if current_hovered == self:
			_clear_hover_state(false)

func set_available_for_placement(is_available: bool) -> void:
	if is_available_for_placement == is_available:
		return
	is_available_for_placement = is_available
	_update_visualization()

func set_parent_section_ai_restricted(is_restricted: bool) -> void:
	if parent_section_ai_restricted == is_restricted:
		return
	parent_section_ai_restricted = is_restricted
	_update_visualization()

func _input( event: InputEvent) -> void:
	if check_for_release:
		# Place on action release
		if event.is_action_released("hold_draggable") and hover_draggable and is_effectively_enabled():
			placed_draggable_item = hover_draggable
			hover_draggable = null

			is_available_for_placement = false
			placed_draggable_item.placed = true
			placed_draggable_item.lane_index = lane_index
			placed_draggable_item.set_collision_layer(
				placed_draggable_collision_layer
			)
			placed_draggable_item.add_to_group("Obstacles")

			place_sound_player.play()
			GameManager.placed_draggable.emit(placed_draggable_item)

			current_hovered = null
			_update_visualization()

			for area in all_drop_areas:
				if area != self:
					area._update_visualization()

func _on_mouse_entered_area_signal() -> void:
	if (
		is_effectively_enabled()
		and GameManager.current_draggable
		and Input.is_action_pressed("hold_draggable")
	):
		if current_hovered and current_hovered != self:
			current_hovered._clear_hover_state(true)
		current_hovered = self

		for area_to_hide in all_drop_areas:
			if area_to_hide != self:
				area_to_hide.visualization.hide()

		_set_visualization_colors(
			base_visualization_color_hover, line_visualization_color_hover
		)
		visualization.show()

		check_for_release = true
		if GameManager.current_draggable:
			GameManager.current_draggable.hide()
			hover_draggable = GameManager.current_draggable.duplicate()
			hover_draggable.placed = true
			add_child(hover_draggable)
			hover_draggable.position = Vector3.ZERO
			hover_draggable.show()

func _on_mouse_exited_area_signal() -> void:
	check_for_release = false
	if current_hovered == self:
		_clear_hover_state(true)

func _clear_hover_state(restore_other_visualizations: bool) -> void:
	if GameManager.current_draggable and hover_draggable:
		GameManager.current_draggable.show()

	if hover_draggable:
		if hover_draggable.get_parent() == self:
			remove_child(hover_draggable)
		hover_draggable.queue_free()
		hover_draggable = null

	if current_hovered == self:
		current_hovered = null

	_set_visualization_colors(
		base_visualization_color_available, line_visualization_color_available
	)
	_update_visualization()

	if restore_other_visualizations:
		for area in all_drop_areas:
			if area != self:
				area._update_visualization()

func _on_body_entered(body: Node3D) -> void:
	if body is AiRunner:
		ai_runner_physically_occupying = true
		_update_visualization()
		if current_hovered == self:
			_clear_hover_state(true)

func _on_body_exited(body: Node3D) -> void:
	if body is AiRunner:
		ai_runner_physically_occupying = false
		_update_visualization()

func _set_visualization_colors(base_color: Color, line_color: Color) -> void:
	var mat := visualization.get_active_material(0)
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("base_color", base_color)
		mat.set_shader_parameter("line_color", line_color)
