extends Button

func _pressed() -> void:
	get_tree().quit()


func _on_host_button_pressed() -> void:
	hide()
