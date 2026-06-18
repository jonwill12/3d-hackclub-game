extends CharacterBody3D

const SPEED = 4.0

var health = 1
var attack_cooldown = 1.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer


var player: Node3D = null
var ready_to_move := false


func _ready():
	add_to_group("Enemies")
	if anim_player:
		anim_player.play("r/walking ani lopped")

	# wait for multiplayer + scene spawn timing
	await get_tree().physics_frame
	await get_tree().physics_frame

	ready_to_move = true


func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

	# always try to find player if missing
	if player == null or not is_instance_valid(player):
		player = _get_player()

	if player == null or not ready_to_move:
		move_and_slide()
		return

	# --- MOVE DIRECTLY TOWARD PLAYER (NO NAV ISSUES) ---
	var dir := player.global_position - global_position
	dir.y = 0

	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

	# --- LOOK AT PLAYER ---
	var look_target = Vector3(
		player.global_position.x,
		global_position.y,
		player.global_position.z
	)

	look_at(look_target)
	rotate_y(deg_to_rad(180))

	# --- ATTACK ---
	var distance_to_player = global_position.distance_to(player.global_position)

	attack_cooldown -= delta
	if distance_to_player < 2.0 and attack_cooldown <= 0:
		if player.has_method("take_damage"):
			player.take_damage(10)
		attack_cooldown = 1.0


func _get_player() -> Node3D:
	var nodes = get_tree().get_nodes_in_group("player")

	for n in nodes:
		if n is Node3D:
			return n

	return null


func hitscan_hit(damage, direction, position):
	take_damage(damage)


func take_damage(amount):
	health -= amount
	print("Enemy hit, HP:", health)

	if health <= 0:
		print("Enemy died")

	var gm = get_tree().get_first_node_in_group("GameManager")
	if gm:
		gm.enemy_killed()

	var spawner = get_tree().get_first_node_in_group("EnemySpawner")
	print("Spawner found:", spawner)

	if spawner:
		spawner.spawn_enemy()
		anim_player.play("r/walking ani lopped")

		queue_free()
