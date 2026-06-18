extends Area3D

func _on_body_entered(body):
	if body.name == "PlayerCharacter":
		# Return to main menu
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://world.tscn")
		# Save that Level 1 is unlocked
		var save = ConfigFile.new()
		save.set_value("levels", "level_1_unlocked", true)
		save.save("user://save.cfg")
		
