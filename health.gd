extends CanvasLayer

var player
var label = Label.new()

func _ready():
	label.add_theme_font_size_override("font_size", 32)
	label.position = Vector2(20, 20)
	add_child(label)
	label.text = "Health: 100"
	hide()

func _process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player:
			show()
	
	if player and is_instance_valid(player):
		label.text = "Health: " + str(player.health)
		if player.is_dead:
			hide()
	elif player and not is_instance_valid(player):
		hide()
		player = null
