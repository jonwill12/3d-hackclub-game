extends Node3D

@onready var spawn = $SpawnPoint
@onready var player = $PlayerCharacter

func _ready():
	player.global_position = spawn.global_position
