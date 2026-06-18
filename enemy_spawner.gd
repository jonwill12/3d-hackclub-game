extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_points: Array[Node3D]

func _ready():
	add_to_group("EnemySpawner")
	print("Spawner is ACTIVE")
	await get_tree().process_frame

func spawn_enemies(count: int):
	for i in range(count):
		spawn_enemy()
		await get_tree().process_frame
	print("Spawned ", count, " enemies")

func spawn_enemy():
	if enemy_scene == null:
		push_error("No enemy scene set!")
		return
	if spawn_points.size() == 0:
		push_error("No spawn points set!")
		return
	var enemy = enemy_scene.instantiate()
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_point.global_position + Vector3(0, 1, 0)
	print("Enemy spawned at: ", enemy.global_position)
	await get_tree().process_frame
	var anim = enemy.find_child("AnimationPlayer", true, false)
	var skeleton = enemy.find_child("Skeleton3D", true, false)
	if anim and skeleton:
		anim.root_node = anim.get_path_to(skeleton.get_parent())
		print("Found anim player, playing...")
		anim.play("r/walking ani lopped")
	else:
		print("AnimationPlayer not found!")
