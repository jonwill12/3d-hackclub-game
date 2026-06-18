extends CanvasLayer

@onready var label: Label = $ObjectiveLabel

func _ready() -> void:
	var gm = get_tree().get_first_node_in_group("GameManager")

	if gm:
		print("Connected to GameManager")
		gm.objective_updated.connect(update_text)
		gm.game_won.connect(win_screen)
	else:
		print("GameManager not found!")

func update_text(text: String) -> void:
	print("Received objective:", text)
	label.text = text

func win_screen() -> void:
	print("Win screen called")
	label.text = "OBJECTIVE COMPLETE!"
