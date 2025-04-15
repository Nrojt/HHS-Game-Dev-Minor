extends Area3D

@onready var visualization : MeshInstance3D = $Visualization

func _mouse_enter() -> void:
	visualization.show()
	
func _mouse_exit() -> void:
	visualization.hide()
