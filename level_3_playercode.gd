extends CharacterBody3D

@export_group("Jump variables")
@export var jump_height: float = 2.0
@export var jump_time_to_peak: float = 0.3
@export var jump_time_to_fall: float = 0.25
@export var jump_cooldown: float = 0.25
@export var hit_ground_cooldown: float = 0.1
var hit_ground_cooldown_ref: float
var jump_cooldown_ref: float
@export var nb_jumps_in_air_allowed: int = 1
var nb_jumps_in_air_allowed_ref: int
var jump_buff_on: bool = false
var buffered_jump: bool = false
@export var coyote_jump_cooldown: float = 0.3
var coyote_jump_cooldown_ref: float
var coyote_jump_on: bool = false
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak


#health
@onready var death_screen = $"Death" # it says Node not found: "Death" (relative to "/root/map/Player/Camera3D/FpsHands") but it still works and i didnt tell it to look thare but whatever 
@export_group("health variables")
@export var max_health: int = 100
var health: int

#gravity 
@export_group("Gravity variables")
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-1.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)


var is_dead: bool = false
@export_group("Spawn variable")
@export var spawns: PackedVector3Array = [
	Vector3(5, 2, 5)
]

func _ready() -> void:
	health = max_health
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_start_position = camera.position
	hit_ground_cooldown_ref = hit_ground_cooldown
	jump_cooldown_ref = jump_cooldown
	jump_cooldown = -1.0
	nb_jumps_in_air_allowed_ref = nb_jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	
func process_command(text: String):
	var parser = preload("res://level 3/ AICommandParser.gd").new()
	var command = parser.parse_command(text)
	var enemy = get_tree().get_first_node_in_group("Enemies")
	if enemy:
		enemy.receive_command(command)
	else:
		print("No enemy found")

# DAMAGE
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()
	if is_dead:
		return
		health -= amount
	
	if health <= 0:
		die()

# DEATH
func die():
	if is_dead:
		return
	is_dead = true
	health = 0
	death_screen.show_death_screen()

#gravity fro jumping 
func gravity_apply(delta: float) -> void:
	if !is_on_floor():
		if velocity.y > 0.0:
			velocity.y += jump_gravity * delta
		else:
			velocity.y += fall_gravity * delta
			
			
@export_group("Movement")
@export var ACCEL := 10
@export var DEACCEL := 30
@export var SPEED := 3.0
@export var SPRINT_MULT := 3


@export_group("Sensitivity")
@export var MOUSE_SENSITIVITY := 0.09
@export var STICK_SENSITIVITY := 150

@export_group("Camera")
@export var clamp_max := 1.4
@export var clamp_min := -1.4
@export var bobbing := false
@export var BOB_SPEED := .1
@export var BOB_SIZE := .0025

@export_category("Actions")
@export_group("Move")
@export var move_left_action := "play_char_move_left_action"
@export var move_right_action := "play_char_move_right_action"
@export var move_forward_action := "play_char_move_forward_action"
@export var move_backward_action := "play_char_move_backward_action"
@export var sprint_action := "play_char_run_action"


@export_group("Look")
@export var look_left_action := "look_left"
@export var look_right_action := "look_right"
@export var look_up_action := "look_up"
@export var look_down_action := "look_down"


@onready var camera : Camera3D = get_node("Camera3D")
var camera_start_position : Vector3
var dir = Vector3.ZERO
var running = false

func _input(event):
	# Controls player camera with mouse.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera.rotation.x = camera.rotation.x + clampf(
			deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1),
			clamp_min,
			clamp_max,
		)
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
	
	else:
		# Release/Grab Mouse for debugging. You can change or replace this.
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	# Controls player camera with gamepad
	var look_vector = Input.get_vector(look_right_action,look_left_action,look_down_action,look_up_action)
	#var look_vector = Vector2.ZERO
	#look_vector.x = Input.get_action_strength("look_left") - Input.get_action_strength("look_right")
	#look_vector.y = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	
	self.rotate_y(deg_to_rad(look_vector.x) * STICK_SENSITIVITY * delta)
	camera.rotate_x(deg_to_rad(look_vector.y) * STICK_SENSITIVITY * delta)
	camera.rotation.x = clampf(camera.rotation.x, -1.4, 1.4)

func _physics_process(delta):
	var moving = false
# Apply custom gravity
	gravity_apply(delta)

# Timers
	if jump_cooldown > 0:
		jump_cooldown -= delta

	if hit_ground_cooldown > 0:
		hit_ground_cooldown -= delta

	if coyote_jump_cooldown > 0:
		coyote_jump_cooldown -= delta
		coyote_jump_on = true
	else:
		coyote_jump_on = false

# Detect landing
	if is_on_floor():
		nb_jumps_in_air_allowed = nb_jumps_in_air_allowed_ref
		coyote_jump_cooldown = coyote_jump_cooldown_ref
		hit_ground_cooldown = hit_ground_cooldown_ref
	else:
		if hit_ground_cooldown <= 0:
			nb_jumps_in_air_allowed = max(nb_jumps_in_air_allowed, 0)

# Jump buffer
	if Input.is_action_just_pressed("ui_accept"):
		buffered_jump = true

# Jump
	if buffered_jump:
		if (is_on_floor() or coyote_jump_on or nb_jumps_in_air_allowed > 0) and jump_cooldown <= 0:
			velocity.y = jump_velocity
			buffered_jump = false
			jump_cooldown = jump_cooldown_ref
			coyote_jump_on = false

		if !is_on_floor():
			nb_jumps_in_air_allowed -= 1

# Cancel jump buffer if button released
	if Input.is_action_just_released("ui_accept"):
		buffered_jump = false
		
		
	# This just controls acceleration. 
	var accel
	if dir.dot(velocity) > 0:
		accel = ACCEL
		moving = true
	else:
		accel = DEACCEL
		moving = false


	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector(move_left_action, move_right_action, move_forward_action, move_backward_action)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)) * accel * delta
	
	# Run if sprint btn pressed and player moving. Once stopped, disable run
	if Input.is_action_just_pressed(sprint_action) or Input.is_action_pressed(sprint_action):
		running = true
	if direction == Vector3.ZERO:
		running = false
	if running:
		direction = direction * SPRINT_MULT

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Push objects
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider(0)
		var inertia = 50
		if collider is RigidBody3D:
			if collider.mass < inertia:
				inertia = collider.mass
			collider.apply_central_impulse(-get_slide_collision(i).get_normal()*inertia)
	
	# Bobbing animation
	if bobbing:
		if velocity and is_on_floor():
			var bob = Vector3.ZERO
			var actual_bob_speed = velocity.length()/(SPEED/2) * BOB_SPEED
			var actual_bob_size = velocity.length()/(SPEED/2) * BOB_SIZE
			bob.y += sin(Engine.get_process_frames() * actual_bob_speed) * actual_bob_size
			bob.x += cos(Engine.get_process_frames() * actual_bob_speed/2) * actual_bob_size * 2
			camera.position += bob
		elif camera.position != camera_start_position:
			camera.position = lerp(camera.position, camera_start_position, 2 * (1/.3) * delta)


func _on_fps_hands_give_damage(obj:Node3D, damage:float, point:Vector3):
	var label := Label3D.new()
	label.text = str(int(damage))
	label.pixel_size = .0015
	label.fixed_size = true
	label.no_depth_test = true
	label.position = point
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	
	var timer := Timer.new()
	timer.wait_time = .5
	timer.autostart = true
	timer.connect("timeout", label.queue_free)
	
	get_tree().root.add_child(label)
	label.add_child(timer)


func _on_fps_hands_update_ammo(magazine, inventory_ammo, ammo_type):
	$UI/AmmoLabel.text = str(magazine) +"/"+ str(inventory_ammo) +"\n"+ ammo_type


func _on_fps_hands_aiming(ads:bool):
	if !ads:
		$UI/CenterContainer/Crosshair.show()
	else:
		$UI/CenterContainer/Crosshair.hide()
