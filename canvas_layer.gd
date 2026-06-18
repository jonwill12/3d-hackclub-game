extends CanvasLayer

func _ready():
	hide()
	$VBoxContainer/Button.pressed.connect(_on_main_menu_pressed)

func show_death_screen(is_spectating: bool) -> void:
	show()
	if is_spectating:
		$VBoxContainer/SpectateLabel.text = "Spectating other players..."
	else:
		$VBoxContainer/SpectateLabel.text = "All players eliminated."

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")
	
