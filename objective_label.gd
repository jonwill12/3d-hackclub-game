extends CanvasLayer

@onready var label = $ObjectiveLabel

func _ready():
	var gm = get_tree().get_first_node_in_group("GameManager")
	if gm:
		gm.objective_updated.connect(update_text)
		gm.game_won.connect(win_screen)

func update_text(text):
	label.text = text

func win_screen():
	label.text = "OBJECTIVE COMPLETE!"
