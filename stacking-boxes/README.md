﻿# Stacking Boxes

A physics simulation of stacking objects, kind of like tetris but with 3D boxes. The goal is to stack as many boxes as
possible without them falling over. The game is over when a box falls off the platform.
Made for the game dev minor at Zoetemeer

## Builds

Windows and linux builds are exported to the `build` folder.

## Controls

Controller support works, except for the pause menu.
Mouse and keyboard controls are standard WASD and mouse look.
Drop the droppable by pressing the left mouse button (Bottom button on controller, 'A' on Xbox, 'X' on Playstation).
Pause the game with the escape key (Start button on controller).
There is a debug menu available by clicking F3, using an asset.
By pressing TAB, you can switch between the three camera modes.

## Saving
The options, keybinds and high score are saved in the `user://` folder. Depending on operating system, this is located in:
* Windows: %APPDATA%\Godot\app_userdata\stacking_boxes
* Linux: ~/.local/share/godot/app_userdata/stacking_boxes

The keybinds can be reset to default. To reset the high score and options, delete the `.cfg` files in the above mentioned folder.


## Assets

### Textures and Models

- [Food](https://kenney.nl/assets/food-kit)
- [Level Assets](https://kaylousberg.itch.io/kaykit-dungeon-remastered) - Free version
- [Sky](https://polyhaven.com/a/autumn_field_puresky)

### Scripts

- [Free look camera](https://github.com/MarcPhi/godot-free-look-camera) (has been modified)

### Music and Sound

- All music made by me
- Sound effects are from [pixabay.com](https://pixabay.com/sound-effects), cut down and edited by me
    - [wood.ogg](https://pixabay.com/sound-effects/hitting-wood-6791/)
    - [apple.ogg](https://pixabay.com/sound-effects/apple-crunch-215258/)
    - [generic_hit.ogg](https://pixabay.com/sound-effects/book-falling-81232/)
    - [glass.ogg](https://pixabay.com/sound-effects/falling-glass-42739/)
    - [bag.ogg](https://pixabay.com/sound-effects/dropping-bag-95101/)

## Addons

- [debug menu](https://github.com/godot-extended-libraries/godot-debug-menu) - For performance and debug information
  during development

## GenAI usage

### GameManager.get_object_height()

This function is used to get the height of an object. It was written by Deepseek R1, with little to no adjustment by me.
It is used to get the height of an object, which is needed for collision detection. The function is used in the
`GameManager` script.
While I had considered using Raycasts before asking Deepseek R1, I had originally dropped the idea due to the varying
sizes of the droppable items, making the raycast lenght unpredictable.
For the complete chats, see `gen_ai_conversations/Godot raycast collision detection.html` (Deepseek, 2025a) and
`gen_ai_conversations/Godot raycast collision detection 2.html` (Deepseek, 2025b).

```gdscript
func get_object_height(item: Node3D) -> float:
	var item_max_height: float = 0.0
	var item_min_height: float = 0.0

	for child in item.get_children():
		if child is CollisionShape3D:
			var shape: Shape3D = child.shape
			var global_pos: Vector3 = child.global_transform.origin

			if shape is BoxShape3D:
				var extents: float = shape.size.y / 2
				item_max_height = max(item_max_height, global_pos.y + extents)
				item_min_height = min(item_min_height, global_pos.y - extents)
			elif shape is SphereShape3D:
				var radius: float = shape.radius
				item_max_height = max(item_max_height, global_pos.y + radius)
				item_min_height = min(item_min_height, global_pos.y - radius)
			elif shape is CapsuleShape3D:
				var height: float = shape.height
				var radius: float = shape.radius
				item_max_height = max(item_max_height, global_pos.y + height/2 + radius)
				item_min_height = min(item_min_height, global_pos.y - height/2 - radius)
			elif shape is CylinderShape3D:
				var height: float = shape.height
				var radius: float = shape.radius
				item_max_height = max(item_max_height, global_pos.y + height/2 + radius)
				item_min_height = min(item_min_height, global_pos.y - height/2 - radius)
			elif shape is ConvexPolygonShape3D:
				var points: PackedVector3Array = shape.points
				if points.size() > 0:
					var local_bounds_min: float = points[0].y
					var local_bounds_max: float = points[0].y
					for point in points:
						local_bounds_min = min(local_bounds_min, point.y)
						local_bounds_max = max(local_bounds_max, point.y)
					# Apply scale and rotation from global transform
					var transformed_extents = child.global_transform.basis * Vector3(0, (local_bounds_max - local_bounds_min) / 2, 0)
					var center_offset: float = (local_bounds_max + local_bounds_min) / 2
					item_max_height = max(item_max_height, global_pos.y + center_offset + abs(transformed_extents.y))
					item_min_height = min(item_min_height, global_pos.y + center_offset - abs(transformed_extents.y))
			else:
				print("Unknown shape: ", shape)

	return (item_max_height - item_min_height)
```

#### Reference

Deepseek. (2025a, February 14)[Large Language Model Deepseek R1]. https://t3.chat/.
Deepseek. (2025b, February 19)[Large Language Model Deepseek R1]. https://t3.chat/.