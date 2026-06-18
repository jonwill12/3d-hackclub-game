extends CharacterBody3D

class_name PlayerCharacter2

@export_group("Movement variables")
var move_speed: float
var move_accel: float
var move_deccel: float
var input_direction: Vector2
var move_direction: Vector3
var desired_move_speed: float
@export var desired_move_speed_curve: Curve
@export var max_desired_move_speed: float = 30.0
@export var in_air_move_speed_curve: Curve
@export var hit_ground_cooldown: float = 0.1
var hit_ground_cooldown_ref: float
@export var bunny_hop_dms_incre: float = 3.0
@export var auto_bunny_hop: bool = false
var last_frame_position: Vector3
var last_frame_velocity: Vector3
var was_on_floor: bool
var walk_or_run: String = "WalkState"
@export var base_hitbox_height: float = 2.0
@export var base_model_height: float = 1.0
@export var height_change_duration: float = 0.15

@export_group("Idle variables")
@export var idle_deccel: float = 10.0

@export_group("Crouch variables")
@export var crouch_speed: float = 6.0
@export var crouch_accel: float = 12.0
@export var crouch_deccel: float = 11.0
@export var continious_crouch: bool = false
@export var backward_crouch_speed_multiplier : float = 0.7
@export var crouch_hitbox_height: float = 1.2
@export var crouch_model_height: float = 0.6

@export_group("Walk variables")
@export var walk_speed: float = 9.0
@export var walk_accel: float = 11.0
@export var walk_deccel: float = 10.0
@export var backward_walk_speed_multiplier : float = 0.75

@export_group("Run variables")
@export var run_speed: float = 12.0
@export var run_accel: float = 10.0
@export var run_deccel: float = 9.0
@export var continious_run: bool = false
@export var backward_run_speed_multiplier : float = 0.7

@export_group("Jump variables")
@export var jump_height: float = 2.0
@export var jump_time_to_peak: float = 0.3
@export var jump_time_to_fall: float = 0.25
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak
@export var jump_cooldown: float = 0.25
var jump_cooldown_ref: float
@export var nb_jumps_in_air_allowed: int = 1
var nb_jumps_in_air_allowed_ref: int
var jump_buff_on: bool = false
var buffered_jump: bool = false
@export var coyote_jump_cooldown: float = 0.3
var coyote_jump_cooldown_ref: float
var coyote_jump_on: bool = false


@export_group("Gravity variables")
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)

@export_group("Keybind variables")
var move_forward_action: StringName
var move_backward_action: StringName
var move_left_action: StringName
var move_right_action: StringName
var run_action: StringName
var crouch_action: StringName
var jump_action: StringName

#spawn
@export var spawns: PackedVector3Array = ([
	Vector3(5, 2, 5),
])

#spectateing code 
var is_dead = false
var spectate_target_index = 0

@rpc("any_peer")
func take_damage(amount: int) -> void:
	health -= amount
	print("Player health: ", health)
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	print("Player died")
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		start_spectating()

func start_spectating() -> void:
	var players = get_tree().get_nodes_in_group("player")
	players.erase(self)
	if players.size() == 0:
		show_death_screen()
	else:
		spectate_target_index = 0
		spectate(players[spectate_target_index])

func show_death_screen() -> void:
	var death_screen = preload("res://death_screen.tscn").instantiate()
	add_child(death_screen)
	death_screen.show_death_screen(false)

func spectate(target: Node3D) -> void:
	# move our camera to follow target
	cam.current = false
	# find target's camera and make it current
	var target_cam = target.find_child("Camera", true, false)
	if target_cam:
		target_cam.current = true
	print("Spectating: ", target.name)

#references variables
@onready var cam_holder: Node3D = $CameraHolder
@onready var cam: Camera3D = %Camera
@onready var model: MeshInstance3D = $Model
@onready var hitbox: CollisionShape3D = $Hitbox
@onready var state_machine: Node = $StateMachine
@onready var hud: CanvasLayer = $HUD
@onready var input_management_component: InputManagementComponent = %InputManagementComponent
@onready var ceiling_check: RayCast3D = %CeilingCheck
@onready var floor_check: RayCast3D = %FloorCheck

var health = 100

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	hit_ground_cooldown_ref = hit_ground_cooldown
	jump_cooldown_ref = jump_cooldown
	jump_cooldown = -1.0
	nb_jumps_in_air_allowed_ref = nb_jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	global_position = spawns[randi() % spawns.size()]
	if not is_multiplayer_authority(): 
		cam.current = false
		return
	cam.current = true


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	modify_physics_properties()
	move_and_slide()

func modify_physics_properties() -> void:
	last_frame_position = global_position
	last_frame_velocity = velocity
	was_on_floor = !is_on_floor()

func gravity_apply(delta: float) -> void:
	if not is_on_floor():
		if velocity.y >= 0.0: velocity.y += jump_gravity * delta
		elif velocity.y < 0.0: velocity.y += fall_gravity * delta

func tween_hitbox_height(state_hitbox_height : float) -> void:
	var hitbox_tween: Tween = create_tween()
	if hitbox != null:
		hitbox_tween.tween_method(func(value): set_hitbox_height(value), hitbox.shape.height,
		state_hitbox_height, height_change_duration)
	else:
		hitbox_tween.tween_interval(0.1)
	hitbox_tween.finished.connect(Callable(hitbox_tween, "kill"))

func set_hitbox_height(value: float) -> void:
	if hitbox.shape is CapsuleShape3D:
		hitbox.shape.height = value

func tween_model_height(state_model_height : float) -> void:
	var model_tween: Tween = create_tween()
	if model != null:
		model_tween.tween_property(model, "scale:y",
		state_model_height, height_change_duration)
	else:
		model_tween.tween_interval(0.1)
	model_tween.finished.connect(Callable(model_tween, "kill"))
