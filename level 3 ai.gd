extends CharacterBody3D
const SPEED = 2.0
var health = 1
var attack_cooldown = 2.0
var dead = false
var can_move = false
@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var player: Node3D = null
var ready_to_move := false
var anger = 0
var npc = null


func _ready():
	add_to_group("Enemies")
	add_to_group("level3 npc")
	player = get_tree().get_first_node_in_group("player")
	npc = get_tree().get_first_node_in_group("level3 npc")
	

func npc_say(text: String):
	var chat = get_tree().get_first_node_in_group("ChatUI")

	if chat:
		chat.add_message("NPC", text)
		
#how mad the enimy is if hes above a certain threshold   he attacts you 
func receive_message(message:String):
	message = message.to_lower()
#this work aslong as the message has the words in them so if its "die you dumb b" it works cus it has die 
#also im have it let up like this as opposed to useing arrays  so certain words have certain responses 
	if "fuck you" in message or "bitch" in message:
		anger += 50
		npc_say("How dare you!")
	
	elif "asshole" in message or "ahole" in message:
		anger += 50
		npc_say("That isn't very nice.")
		
	elif "stupid" in message or "idiot" in message:
		anger += 25
		npc_say("You're asking for trouble.")
	
	elif  "dumb" in message or "moron" in message:
		anger += 25
		npc_say("You're asking for trouble.")
		
	elif "kill your self" in message or "kys" in message:
		anger += 50
		npc_say("You shouldn't have said that.")
	
	elif "loser" in message or "pathetic" in message:
		anger += 25
		npc_say("That isn't very nice.")
		
	elif "shut up" in message:
		anger += 25
		npc_say("That hurt my feelings.")
		
	elif "i will kill you" in message or "your dead" in message:
		anger += 50
		npc_say("Then let's settle this.")
	
	elif "you're dead" in message or "kill yourself" in message:
		anger += 50
		npc_say("You're going to regret saying that.")
	
	elif "drop dead" in message or "i'll kill you" in message:
		anger += 50
		npc_say("Enough talk.")
		
	elif "die" in message:
		anger += 50
		npc_say("You're not leaving here alive.")
		
	elif "hello" in message or "test" in message:
		npc_say("NPC: Hello!")

	check_anger()


func check_anger():
	if anger >= 50:
		get_angry()

#start walking to player and attacking 
func get_angry():
	print("NPC: how dare you!")
	anim_player.play("r/walking ani lopped")
	await get_tree().physics_frame
	await get_tree().physics_frame
	ready_to_move = true
	can_move = true
	

func _physics_process(delta):
	if !can_move:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	move_and_slide()

	if dead:
		return

	if player == null:
		return
	# gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0



	# LOOK AT PLAYER
	var look_target = Vector3(
		player.global_position.x,
		global_position.y,
		player.global_position.z
	)
	move_and_slide()

	look_at(look_target)
	rotate_y(deg_to_rad(180))

	# ATTACK
	var distance_to_player = global_position.distance_to(player.global_position)

	attack_cooldown -= delta

	if distance_to_player < 1.0 and attack_cooldown <= 0:
		if player.has_method("take_damage"):
			player.take_damage(10)

		attack_cooldown = 1.0


# HIT / DAMAGE
func hitscan_hit(damage, direction, position):
	take_damage(damage)


func take_damage(amount):
	if dead:
		return

	health -= amount

	if health <= 0:
		can_move = false
		die()


func die():
	dead = true

	velocity = Vector3.ZERO
	set_physics_process(false)

	anim_player.stop()
	anim_player.play("e/mixamo_com")
	#wait till anim is done to spawn next enimy
	
	await get_tree().create_timer(3).timeout


func _on_input_box_text_submitted(new_text: String) -> void:
	var chat = get_tree().get_first_node_in_group("ChatUI")

	if chat:
		chat.add_message("PLAYER", new_text)

	receive_message(new_text)
	
