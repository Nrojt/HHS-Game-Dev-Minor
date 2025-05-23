extends RigidBody3D
class_name DroppableBase

@export_group("Physics")
@export var stillness_threshold: int = 10
@export var time_until_static: float = 4.0
@export var ground_check_additional_ray_length: float = 0.6
@export var raycast_timeout: float = 4.0

@export_flags_3d_physics var ground_collision_layer: int = 1
@export_group("Sound")
@export var drop_sound: AudioStream = preload("res://assets/sounds/generic_hit.ogg")

var time_since_moved: float = 0.0
var time_raycasted: float = 0.0
var is_holding: bool = true
var is_static: bool = false
var ground_ray: RayCast3D

@onready var audio_player: AudioStreamPlayer3D = %AudioPlayer


# TODO: Ray cast is not always working, why?

func _ready():
	# add the sound
	audio_player.stream = drop_sound

	# Create raycast as child
	ground_ray = RayCast3D.new()
	add_child(ground_ray)
	ground_ray.collision_mask = ground_collision_layer
	ground_ray.exclude_parent = true
	# Calculate ray length based on object height
	var object_height: float = GameManager.get_object_height(self) + ground_check_additional_ray_length
	ground_ray.target_position = Vector3(0, -object_height, 0)
	ground_ray.enabled = true


func _physics_process(delta: float) -> void:
	if is_static || is_holding:
		return

	# Update raycast position while maintaining world-space orientation
	ground_ray.global_transform = Transform3D.IDENTITY.translated(global_transform.origin)

	var is_moving: bool = linear_velocity.length() > stillness_threshold

	if is_moving:
		time_since_moved = 0.0
		time_raycasted = 0.0
	else:
		time_since_moved += delta
		time_raycasted += delta

		var colliding: bool = ground_ray.is_colliding()

		if time_since_moved >= time_until_static and colliding:
			make_static()
		elif time_raycasted >= raycast_timeout:
			print("Raycast timeout - forcing static : ", colliding)
			make_static()


func make_static() -> void:

	is_static = true
	var static_body = StaticBody3D.new()

	# adding the static body to a group
	static_body.add_to_group("pile_items")

	# Add to scene tree
	get_parent().add_child(static_body)

	# Set global transform before adding children
	static_body.global_transform = global_transform

	# Copy all relevant children @formatter:off
	for child in get_children():
		if child is Node3D and child is not RayCast3D:
			var duplicated_child: Node = child.duplicate()

			static_body.add_child(duplicated_child)
			duplicated_child.transform = child.transform
			duplicated_child.owner = static_body
		
		child.queue_free()
	GameManager.calculate_max_height(static_body)
	enable_new_spawn()
	

# @formatter:on

# Removing ourselves from the scene
func enable_new_spawn() -> void:
	GameManager.current_droppable = null
	queue_free()


func _on_body_entered(body):
	# play the sound
	audio_player.play()
