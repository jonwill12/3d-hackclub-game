extends Node3D

var current_weapon : WeaponSlot
var point_of_collision : Vector3 = Vector3.ZERO
var rng : RandomNumberGenerator

@onready var weapon_manager : Node3D = %WeaponManager

func get_current_weapon(current_weapon_ref : WeaponSlot) -> void:
	current_weapon = current_weapon_ref
	
func shoot() -> void:
	if !current_weapon.resources.is_shooting and (
	(current_weapon.resources.total_ammo_in_mag > 0 and current_weapon.resources.total_ammo_in_mag >= current_weapon.resources.nb_proj_shots_at_same_time)
	or 
	(current_weapon.resources.all_ammo_in_mag and weapon_manager.ammo_manager.ammo_dict[current_weapon.resources.ammo_type] > 0 and \
	weapon_manager.ammo_manager.amm_dict[current_weapon.resources.ammo_type] >= current_weapon.resources.nb_proj_shots_at_same_time)
	) and !current_weapon.resources.is_reloading:
		current_weapon.resources.is_shooting = true
		
		for i in range(current_weapon.resources.nb_proj_shots):
			if ((current_weapon.resources.total_ammo_in_mag > 0 and current_weapon.resources.total_ammo_in_mag >= current_weapon.resources.nb_proj_shots_at_same_time) 
			or (current_weapon.resources.all_ammo_in_mag and weapon_manager.ammo_manager.ammo_dict[current_weapon.resources.ammo_type] > 0) and \
			weapon_manager.ammo_manager.ammo_dict[current_weapon.resources.ammo_type] >= current_weapon.resources.nb_proj_shots_at_same_time):
				
				weapon_manager.weapon_sound_management(current_weapon.resources.shoot_sound, current_weapon.resources.shoot_sound_speed)
				
				if current_weapon.resources.shoot_anim_name != "":
					weapon_manager.anim_manager.play_animation("ShootAnim%s" % current_weapon.resources.weapon_name, current_weapon.resources.shoot_anim_speed, true)
				else:
					print("%s doesn't have a shoot animation" % current_weapon.resources.weapon_name)
					
				for j in range(0, current_weapon.resources.nb_proj_shots_at_same_time):
					if current_weapon.resources.all_ammo_in_mag: weapon_manager.ammo_manager.ammo_dict[current_weapon.resources.ammo_type] -= 1
					else: current_weapon.resources.total_ammo_in_mag -= 1
					
					point_of_collision = get_camera_fov()
					
					if current_weapon.resources.type == current_weapon.resources.types.HITSCAN: hitscan_shot(point_of_collision)
					elif current_weapon.resources.type == current_weapon.resources.types.PROJECTILE: projectile_shot(point_of_collision)
					
				if current_weapon.resources.show_muzzle_flash: weapon_manager.display_muzzle_flash()
				
				weapon_manager.camera_recoil_holder.set_recoil_values(current_weapon.resources.base_rot_speed, current_weapon.resources.target_rot_speed)
				weapon_manager.camera_recoil_holder.add_recoil(current_weapon.resources.recoil_val)
				
				await get_tree().create_timer(current_weapon.resources.time_between_shots).timeout
				
			else:
				print("Not enough ammunitions to shoot")
				
		current_weapon.resources.is_shooting = false
		
func get_camera_fov() -> Vector3:  
	var camera : Camera3D = %Camera
	var window : Window = get_window()
	var viewport : Vector2i
	print("camera position: ", camera.global_position)
	
	match window.content_scale_mode:
		window.CONTENT_SCALE_MODE_VIEWPORT:
			viewport = window.content_scale_size
		window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
			viewport = window.content_scale_size
		window.CONTENT_SCALE_MODE_DISABLED:
			viewport = window.get_size()
			
	var raycast_start : Vector3 = camera.project_ray_origin(viewport/2.0)
	var raycast_end : Vector3 = Vector3.ZERO
	if current_weapon.resources.type == current_weapon.resources.types.HITSCAN: raycast_end = raycast_start + camera.project_ray_normal(viewport/2) * current_weapon.resources.max_range 
	if current_weapon.resources.type == current_weapon.resources.types.PROJECTILE: raycast_end = raycast_start + camera.project_ray_normal(viewport/2) * 280
	
	var new_intersection : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_start, raycast_end)
	var intersection : Dictionary = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	print("raycast hit: ", !intersection.is_empty())
	
	if !intersection.is_empty():
		var collision_point : Vector3 = intersection.position
		return collision_point 
	else:
		return raycast_end 
		
func hitscan_shot(point_of_collision_hitscan : Vector3) -> void:
	rng = RandomNumberGenerator.new()
	print("hitscan fired, is_reloading: ", current_weapon.resources.is_reloading)
	
	var spread : Vector3 = Vector3(rng.randf_range(current_weapon.resources.min_spread, current_weapon.resources.max_spread), rng.randf_range(current_weapon.resources.min_spread, current_weapon.resources.max_spread), rng.randf_range(current_weapon.resources.min_spread, current_weapon.resources.max_spread))
	
	var hitscan_bullet_direction : Vector3 = (point_of_collision_hitscan - current_weapon.attack_point.get_global_transform().origin).normalized()
	
	var new_intersection : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(current_weapon.attack_point.get_global_transform().origin, point_of_collision_hitscan + spread + hitscan_bullet_direction * 2)
	new_intersection.collide_with_areas = true
	new_intersection.collide_with_bodies = true 
	var hitscan_bullet_collision : Dictionary = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if hitscan_bullet_collision: 
		print("hit: ", hitscan_bullet_collision.collider.name)
		var collider = hitscan_bullet_collision.collider
		var collider_point : Vector3 = hitscan_bullet_collision.position
		var collider_normal : Vector3 = hitscan_bullet_collision.normal 
		var final_damage : int = 0
		
		
		if collider.is_in_group("Enemies") and collider.has_method("hitscan_hit"):
			final_damage = current_weapon.resources.damage_per_proj * current_weapon.resources.damage_dropoff.sample(point_of_collision_hitscan.distance_to(global_position) / current_weapon.resources.max_range)
			collider.hitscan_hit(final_damage, hitscan_bullet_direction, hitscan_bullet_collision.position)
		
		elif collider.is_in_group("EnemiesHead") and collider.has_method("hitscan_hit"):
			final_damage = current_weapon.resources.damage_per_proj * current_weapon.resources.headshot_damage_mult * current_weapon.resources.damage_dropoff.sample(point_of_collision_hitscan.distance_to(global_position) / current_weapon.resources.max_range)
			collider.hitscan_hit(final_damage, hitscan_bullet_direction, hitscan_bullet_collision.position)
		
		elif collider.is_in_group("HitableObjects") and collider.has_method("hitscan_hit"): 
			final_damage = current_weapon.resources.damage_per_proj * current_weapon.resources.damage_dropoff.sample(point_of_collision_hitscan.distance_to(global_position) / current_weapon.resources.max_range)
			collider.hitscan_hit(final_damage/6.0, hitscan_bullet_direction, hitscan_bullet_collision.position)
			weapon_manager.display_bullet_hole(collider_point, collider_normal)
			
		else:
			weapon_manager.display_bullet_hole(collider_point, collider_normal)
			
func projectile_shot(point_of_collision_projectile : Vector3) -> void:
	rng = RandomNumberGenerator.new()
	
	var spread : Vector3 = Vector3(rng.randf_range(current_weapon.resources.min_spread, current_weapon.resources.max_spread), rng.randf_range(current_weapon.resources.min_spread, current_weapon.resources.max_spread), rng.randf_range(current_weapon.resources.min_spread, current_weapon.resources.max_spread))
	
	var projectile_direction : Vector3 = ((point_of_collision_projectile - current_weapon.attack_point.get_global_transform().origin).normalized() + spread)
	
	var proj_ins : Projectile = current_weapon.resources.proj_ref.instantiate()
	
	proj_ins.global_transform = current_weapon.attack_point.global_transform
	proj_ins.direction = projectile_direction
	proj_ins.damage = current_weapon.resources.damage_per_proj
	proj_ins.time_before_vanish = current_weapon.resources.proj_time_before_vanish
	proj_ins.gravity_scale = current_weapon.resources.proj_gravity_val
	proj_ins.is_explosive = current_weapon.resources.is_proj_explosive
	
	get_tree().get_root().add_child(proj_ins)
	
	proj_ins.set_linear_velocity(projectile_direction * current_weapon.resources.proj_move_speed)
