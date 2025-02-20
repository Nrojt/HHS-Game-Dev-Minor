extends Label

@onready var player := $"../../Player"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Current state: %s" % player.state_machine.current_state.name
