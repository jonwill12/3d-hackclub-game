extends Button

@onready var picture = $VBoxContainer/TextureRect
@onready var label = $VBoxContainer/Label
@onready var lock = $LockIcon

var scene_path = ""

func setup(level_name, image, scene, unlocked):
	label.text = level_name
	picture.texture = load(image)

	scene_path = scene

	lock.visible = !unlocked
	disabled = !unlocked

func _pressed():
	if !disabled:
		get_tree().change_scene_to_file(scene_path)
