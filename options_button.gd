extends Button


func _on_back_pressed() -> void:
	button_pressed = false
	grab_focus()


func _on_host_button_pressed() -> void:
	hide()
