extends CanvasLayer

signal ui_state_changed(new_state : UIState)

enum UIState {
	MAIN_MENU,
	PLAYING,
	GAME_OVER
}

var scenes : Dictionary[UIState, PackedScene] = {
	# Preload the scenes for each UI state
	UIState.MAIN_MENU: preload("uid://bxfwekogpatk1"),
	UIState.PLAYING: preload("uid://c8p4y13l4wjft"),
	UIState.GAME_OVER: preload("uid://tomp5baxqc4m")
}

func _ready():
	# load in main menu scene
	_on_ui_change(UIState.MAIN_MENU)
	
	# Connect the signal
	ui_state_changed.connect(_on_ui_change)
	

	
	
func _on_ui_change(new_state : UIState):
	# remove all children
	for child in get_children():
		child.queue_free()
	# Add the new UI scene
	if new_state in scenes:
		add_child(scenes[new_state].instantiate())
	else:
		push_error("No scene found for UI state: " + str(new_state))
