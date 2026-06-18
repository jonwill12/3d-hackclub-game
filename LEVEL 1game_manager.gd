extends Node

var kills := 0
var kill_goal := 10

signal objective_updated(text)
signal game_won()

func _ready():
	add_to_group("GameManager")
	
func enemy_killed():
	kills += 1
	print("Kills:", kills)

	if kills >= kill_goal:
		game_won.emit()

	objective_updated.emit("Kill Enemies: %d / %d" % [kills, kill_goal])
