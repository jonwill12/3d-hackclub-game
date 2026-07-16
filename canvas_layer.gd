extends CanvasLayer

func _ready():
	hide()
	$VBoxContainer/Button.pressed.connect(_on_main_menu_pressed)

func show_death_screen() -> void:
	show()
	
func _on_main_menu_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var focused = get_viewport().gui_get_focus_owner()
	if focused:
		focused.release_focus()

	get_tree().change_scene_to_file("res://world.tscn")


func _on_button_pressed() -> void:
	hide()
