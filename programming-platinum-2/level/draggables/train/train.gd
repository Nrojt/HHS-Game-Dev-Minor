class_name Train extends DraggableBase
func _ready():
	# Mark trains as ground level obstacles
	set_meta("is_upper_level_obstacle", false)
