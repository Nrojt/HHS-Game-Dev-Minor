extends Control


func _on_master_volume_slider_value_changed(value: float) -> void:
	# Scaling value, so its between 0 and 85 db
	value = (value / 100) * 85 - 85
	
	AudioServer.set_bus_volume_db(0, value)


func _on_key_bind_button_pressed() -> void:
	SignalManager.add_child_scene.emit("uid://bwox3q508ewxc", false)


func _on_back_button_pressed() -> void:
	queue_free()


func _on_v_sync_toggle_toggled(is_button_pressed: Variant) -> void:
	# Toggle between Vsync on and off
	pass # Replace with function body.


func _on_scaling_resolution_value_changed(value: float) -> void:
	# Change the scaling resolution
	pass # Replace with function body.


func _on_fsr_toggle_toggled(is_button_pressed: Variant) -> void:
	# Turn on FSR2
	pass # Replace with function body.
