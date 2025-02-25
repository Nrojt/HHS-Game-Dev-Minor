extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = "Height: %d"  % clamp(GameManager.max_height, 0, abs(GameManager.max_height))
