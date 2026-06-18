extends CharacterBody3D

const SPEED = 5.0

func _physics_process(delta):
	var input_dir = Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * SPEED
	velocity.z = input_dir.z * SPEED

	move_and_slide()
