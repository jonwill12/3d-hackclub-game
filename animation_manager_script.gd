extends Node3D
class_name AnimationManager

var current_weapon: WeaponSlot

# persistent animation values
var current_tilt_val: Vector3 = Vector3.ZERO
var current_sway_pos_val: Vector3 = Vector3.ZERO
var current_sway_rot_val: Vector3 = Vector3.ZERO
var current_bob_val: Vector3 = Vector3.ZERO

# ---------- FIX: properly reference the PLAYER ----------
@export var play_char_ref: CharacterBody3D
@onready var camera_holder: CameraHolder = %CameraHolder
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var weapon_manager: Node3D = %WeaponManager


func get_current_weapon(current_weapon_ref: WeaponSlot) -> void:
	current_weapon = current_weapon_ref


func _process(delta: float) -> void:
	if not current_weapon or not current_weapon.model:
		return

	if play_char_ref == null:
		return

	# SAFE access (no more Node3D crash)
	var input_dir: Vector2 = Vector2.ZERO
	if "input_direction" in play_char_ref:
		input_dir = play_char_ref.input_direction

	var tilt_values: Vector3 = weapon_tilt_calculus(input_dir, delta)
	var sway_values: Array[Vector3] = weapon_sway_calculus(camera_holder.mouse_input, delta)
	var bob_values: Vector3 = weapon_bob_calculus(play_char_ref.velocity.length(), delta)

	weapon_model_positioning(tilt_values, sway_values, bob_values)


# ---------- PROCEDURAL ANIMATION ----------

func weapon_tilt_calculus(play_char_input: Vector2, delta: float) -> Vector3:
	var tilt_target := Vector3.ZERO

	if current_weapon.resources.axis_to_tilt == "X":
		tilt_target.x = play_char_input.x * current_weapon.resources.tilt_rot_amount

	elif current_weapon.resources.axis_to_tilt == "Y":
		tilt_target.y = play_char_input.x * current_weapon.resources.tilt_rot_amount

	elif current_weapon.resources.axis_to_tilt == "Z":
		tilt_target.z = play_char_input.x * current_weapon.resources.tilt_rot_amount

	current_tilt_val = lerp(current_tilt_val, tilt_target, current_weapon.resources.tilt_rot_speed * delta)
	return current_tilt_val


func weapon_sway_calculus(mouse_input: Vector2, delta: float) -> Array[Vector3]:
	if mouse_input.length() <= 4.0:
		current_sway_pos_val = current_sway_pos_val.move_toward(Vector3.ZERO, delta * current_weapon.resources.back_to_origin_pos_speed)
		current_sway_rot_val = current_sway_rot_val.move_toward(Vector3.ZERO, delta * current_weapon.resources.back_to_origin_pos_speed)
	else:
		mouse_input.x = clamp(mouse_input.x, current_weapon.resources.min_sway_val.x, current_weapon.resources.max_sway_val.x)
		mouse_input.y = clamp(mouse_input.y, current_weapon.resources.min_sway_val.y, current_weapon.resources.max_sway_val.y)

		var sway_pos_target := Vector3(
			mouse_input.x * current_weapon.resources.sway_amount_pos,
			-mouse_input.y * current_weapon.resources.sway_amount_pos,
			0.0
		)

		var sway_rot_target := Vector3(
			deg_to_rad(mouse_input.y * current_weapon.resources.sway_amount_rot),
			-deg_to_rad(mouse_input.x * current_weapon.resources.sway_amount_rot),
			0.0
		)

		current_sway_pos_val = lerp(current_sway_pos_val, sway_pos_target, current_weapon.resources.sway_speed_pos * delta)
		current_sway_rot_val = lerp(current_sway_rot_val, sway_rot_target, current_weapon.resources.sway_speed_rot * delta)

	return [current_sway_pos_val, current_sway_rot_val]


func weapon_bob_calculus(vel: float, delta: float) -> Vector3:
	var t = Time.get_ticks_msec() * 0.001

	var bob_target := Vector3.ZERO
	bob_target.y = sin(t * current_weapon.resources.bob_freq) * current_weapon.resources.bob_amount * vel
	bob_target.x = sin(t * current_weapon.resources.bob_freq * 0.5) * current_weapon.resources.bob_amount * vel

	current_bob_val = lerp(current_bob_val, bob_target, current_weapon.resources.bob_speed * delta)
	return current_bob_val


func weapon_model_positioning(tilt_values: Vector3, sway_values: Array[Vector3], bob_values: Vector3) -> void:
	current_weapon.model.position = current_weapon.resources.pos_val[0] + sway_values[0] + bob_values
	current_weapon.model.rotation = current_weapon.resources.pos_val[1] + sway_values[1] + tilt_values


# ---------- ANIMATION ----------

func play_animation(anim_name: String, anim_speed: float, has_to_restart_anim: bool) -> void:
	if not current_weapon or not current_weapon.resources:
		return

	if has_to_restart_anim and anim_player.current_animation == anim_name:
		anim_player.seek(0, true)

	anim_player.play(anim_name, -1, anim_speed)
