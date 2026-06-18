extends Node3D

var player: CharacterBody3D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player:
		global_position = player.global_position
