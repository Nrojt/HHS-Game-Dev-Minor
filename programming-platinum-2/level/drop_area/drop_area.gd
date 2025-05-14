class_name DropArea
extends Area3D

static var current_hovered: DropArea = null
static var all_drop_areas: Array     = []
@export_group("Draggables")
@export_range(0.0, 3.0, 1.0) var lane_index := 1

@export_flags_3d_physics var placed_draggable_collision_layer: int = 1
@export_group("Visualization")
@export var base_visualization_color_hover: Color = Color("#7420c528")
@export var line_visualization_color_hover: Color = Color("#ef8ab137")
@export var base_visualization_color_available: Color = Color("#8BDF3A28")
@export var line_visualization_color_available: Color = Color("#10754E37")

@onready var visualization: MeshInstance3D = $Visualization

var hover_draggable: Draggable
var placed_draggable: Draggable
var enabled : bool = GameManager.game_active


func _ready():
	# Saving the instance
	all_drop_areas.append(self)

	# Giving each droparea a unique material
	var mat: Material = visualization.get_active_material(0)
	if mat:
		visualization.set_surface_override_material(0, mat.duplicate())
	GameManager.game_ended.connect(
		func():
			if placed_draggable:
				placed_draggable.queue_free()
			if hover_draggable:
				hover_draggable.queue_free()
	)
	if enabled:
		_set_visualization_colors(
			base_visualization_color_available,
			line_visualization_color_available
		)
		visualization.show()
	else:
		visualization.hide()
		
	GameManager.game_started.connect(
		func(): 
			enabled = true
			visualization.show()
	)
	GameManager.game_ended.connect(
		func(): 
			enabled = false
			visualization.hide()
	)


func _exit_tree():
	# Removing the instance
	all_drop_areas.erase(self)


func _input(event: InputEvent) -> void:
	if event.is_action_released("hold_draggable") and hover_draggable:
		_set_visualization_colors(
			base_visualization_color_available,
			line_visualization_color_available
		)
		visualization.show()
		placed_draggable = hover_draggable
		hover_draggable = null
		enabled = false
		placed_draggable.placed = true
		placed_draggable.lane_index = lane_index
		placed_draggable.set_collision_layer(placed_draggable_collision_layer)
		placed_draggable.add_to_group("Obstacles")
		GameManager.placed_draggable.emit(GameManager.current_draggable)
		visualization.hide()
		if current_hovered == self:
			current_hovered = null
		_show_all_available_visualizations()


func _mouse_enter() -> void:
	if enabled and GameManager.game_active and GameManager.current_draggable:
		if Input.is_action_pressed("hold_draggable"):
			if current_hovered and current_hovered != self:
				current_hovered._on_hover_lost()
			current_hovered = self
			_hide_all_available_visualizations(self)
			_set_visualization_colors(
				base_visualization_color_hover,
				line_visualization_color_hover
			)
			visualization.show()
			hover_draggable = GameManager.current_draggable.duplicate()
			GameManager.current_draggable.hide()
			hover_draggable.placed = true
			add_child(hover_draggable)
			hover_draggable.position = Vector3.ZERO


func _mouse_exit() -> void:
	if current_hovered == self:
		current_hovered = null
		_on_hover_lost()
		_show_all_available_visualizations()


func _on_hover_lost() -> void:
	_set_visualization_colors(
		base_visualization_color_available,
		line_visualization_color_available
	)
	if enabled:
		visualization.show()
	else:
		visualization.hide()
	GameManager.current_draggable.show()
	if hover_draggable:
		remove_child(hover_draggable)
		hover_draggable = null


func _set_visualization_colors(base_color: Color, line_color: Color) -> void:
	var mat := visualization.get_active_material(0)
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("base_color", base_color)
		mat.set_shader_parameter("line_color", line_color)


static func _hide_all_available_visualizations(except: DropArea = null) -> void:
	for area in all_drop_areas:
		if area != except and area.enabled:
			area.visualization.hide()


static func _show_all_available_visualizations() -> void:
	for area in all_drop_areas:
		if area.enabled:
			area._set_visualization_colors(
				area.base_visualization_color_available,
				area.line_visualization_color_available
			)
			area.visualization.show()
		else:
			area.visualization.hide()
