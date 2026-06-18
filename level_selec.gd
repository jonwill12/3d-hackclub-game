extends CanvasLayer

@export var level_card_scene: PackedScene

var levels = [
	{
		"name": "tutorial",
		"scene": "res://addons/JehenoSimpleFPSWeaponSystem/Maps/Scenes/template_map_scene.tscn",
		"image": "res://textures/Tutorial level.png",
		"unlocked": true
	},
	{
		"name": "Level 1",
		"scene": "res://map.tscn",
		"image": "res://textures/Level pictures/level 1.png",
		"unlocked": false
	},
	{
		"name": "Level 2",
		"scene": "res://Level2.tscn",
		"image": "res://Images/Level2.png",
		"unlocked": false
	}
]

@onready var grid: GridContainer = $PanelContainer/ScrollContainer/GridContainer
@onready var back_button: Button = $PanelContainer/Button

var save: ConfigFile

func create_level_buttons():
	# clear old buttons
	for child in grid.get_children():
		child.queue_free()

	for level in levels:
		var btn = Button.new()
		btn.text = level["name"]

		# icon
		var tex = load(level["image"])
		if tex:
			btn.icon = tex

		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP

		grid.columns = 3

		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		# unlock check from save
		var key = level["name"].to_lower().replace(" ", "_")
		var unlocked = save.get_value("levels", key + "_unlocked", level["unlocked"])

		btn.disabled = not unlocked

		# click to load level
		if unlocked:
			var scene_path = level["scene"]
			btn.pressed.connect(func():
				get_tree().change_scene_to_file(scene_path)
			)

		grid.add_child(btn)
		
func _ready():
	save = ConfigFile.new()
	save.load("user://save.cfg")
	
	create_level_buttons()
	hide()


func _on_level_selecter_button_pressed() -> void:
	show()
