extends CharacterBody3D

class_name lumina_player

var vars : ply_vars = ply_vars.new()

@onready var camera = $Head/Camera
@onready var head = $Head

var alarmed : bool = false

var last_footstep : int = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	give_armour(0)
	%chapter_intro.visible = false
	%fullbright.visible = false

	%use_ray.add_exception(self)

func get_lumina_class():
	return "lumina_player"

func _input(event):
	if event is InputEventMouseMotion:
		vars.mouse_delta = event.relative

	if Input.is_action_just_pressed("ui_cancel"):
		%pause.visible = true
		get_tree().paused = true
		%pause.paused()
	
	if Input.is_action_just_pressed("ui_home"):
		give_armour(10.0)
	
	if Input.is_key_pressed(KEY_KP_7):
		vars.full_bright = !vars.full_bright

	if Input.is_key_pressed(KEY_KP_8):
		vars.noclip = !vars.noclip
	
	if Input.is_key_pressed(KEY_KP_9):
		vars.god_mode = !vars.god_mode

	if Input.is_action_just_pressed("movement_jump") && vars.health <= 0:
		# TODO: util.loadmap
		pass
	
	if Input.is_action_just_pressed("weapon_next"):
		weapon_switch(1)
	
	if Input.is_action_just_pressed("weapon_prev"):
		weapon_switch(-1)
	
	if Input.is_action_pressed("ui_zoom"):
		vars.camera_fov = 40
	else:
		vars.camera_fov = vars.default_fov

	if Input.is_action_just_pressed("ui_use"):
		if %use_ray.is_colliding():
			var use_obj = %use_ray.get_collider()
			if use_obj.has_method("use"):
				use_obj.use()
			else:
				util.playsfx("res://sound/player/deny.wav")
		else:
			util.playsfx("res://sound/player/deny.wav")

func can_power():
	return vars.power > 0 && !vars.power_depleted

func give_armour(value : float):
	if vars.armour >= 100 && value > 0:
		return

	vars.armour += value
	vars.armour = clamp(vars.armour, 0, 100)
	
	if vars.armour <= 0:
		%hud_anim.play("pp_hide")
	else:
		if %PP_num.modulate == Color(1.0, 1.0, 1.0, 0.0):
			%hud_anim.play("pp_show")

func _process(delta):
	if vars.player_frozen:
		return

	rotation.y -= vars.mouse_delta.x * vars.mouse_sense * delta
	head.rotation.x -= vars.mouse_delta.y * vars.mouse_sense * delta
	head.rotation.x = clamp(head.rotation.x, -deg_to_rad(90), deg_to_rad(90))

	%HP_num.text = str(floor(vars.health))
	%PP_num.text = str(floor(vars.armour))
	if vars.weapon_active:
		if get_node("Head").get_node(vars.weapon_active).clip_size > 0:
			%ammo_stack.visible = true
			%clip.text = str(get_node("Head").get_node(vars.weapon_active).clip)
			%ammo.text = str(get_node("Head").get_node(vars.weapon_active).ammo)
		else:
			%ammo_stack.visible = false
	else:
		%ammo_stack.visible = false

	%power_bar.value = vars.power
	%wep_select.visible = vars.weapon_inventory.size() >= 1

	if vars.weapon_active != "":
		%Head.get_node(vars.weapon_active).view_sway += Vector3(vars.mouse_delta.x, vars.mouse_delta.y, 0) * 0.0001

	vars.mouse_delta = Vector2.ZERO

func randomSFX(pack : String, max : int = 4):
	var rand = randi_range(1, max)

	while rand == last_footstep:
		rand = randi_range(1, max)

	util.playsfx3D("res://sound/" + pack + "/" + str(rand) + ".wav", -10.0, 1.0, 10.0, head)
	last_footstep = rand
		

func randomSFX3D(pack : String, max : int = 4, parent : Node = null):
	util.playsfx3D("res://sound/" + pack + str(randi_range(1, max)) + ".ogg", 0.0, 1.0, 10.0, parent)

func weapon_switch(index : int):
	if vars.weapon_inventory.size() == 0:
		return

	vars.weapon_active_index = (vars.weapon_active_index + index) % vars.weapon_inventory.size()
	vars.weapon_active = vars.weapon_inventory[vars.weapon_active_index]

	%label_wep_name.text = get_node("Head").get_node(vars.weapon_active).display_name
	%wep_texture.texture = load("res://mat/ui/img/hud/weapon/" + vars.weapon_active + ".png")

	util.playsfx("res://sound/player/weapon/weapon_select.wav", 0.0, 1.0, head)

	%wep_select_anim.stop()
	if index > 0:
		%wep_select_anim.play("next")
	else:
		%wep_select_anim.play("prev")

func chapter_text(text : String, speed : float = 1):
	%chapter_intro.text = text
	%chapter_intro.get_child(0).speed_scale = speed
	%chapter_intro.get_child(0).play("showanim")
	await get_tree().create_timer(3).timeout
	%chapter_intro.get_child(0).play("fade")


func damage(type : String = "generic", amount : int = 10, knockback : Vector3 = Vector3.ZERO):
	if vars.player_frozen || vars.health <= 0 || util.cheats && vars.god_mode:
		return

	match type:
		"generic":
			pass
		"crush":
			randomSFX3D("player/damage/playercrush", 2, self)
		"fall":
			randomSFX3D("player/damage/playerfall", 2, self)
		#_:
			print("no damage type...")
	
	var multi = randf_range(-1, 1)
	if multi == 0.0:
		multi = 1.0
	
	vars.camera_rotation.z = amount * multi
	camera.rotation_degrees = vars.camera_rotation
	
	vars.movement += Vector3(knockback.x, 0, knockback.z)
	vars.gravity_vec += Vector3(0, knockback.y, 0)
	
	if vars.armour > 0:
		vars.health -= amount * 0.5 # OMG HALF-LIFE REFERENCE OMG XDDDDDDDDDDDDD SO FUNNY LMFAO XD I AM FUCKING RETDDIT KARMA 5000000 REDDIT GOLD WHOLESOME AWARD XDD SO QUIRKY AND FUNY XDX D DD !111 11 11 1111 1 xddd SO HILARIOUS XDDXDDD BIG CHUNGUS ISN'T FUNNY R/HALFLIFE XDDD GET R3KT BOI XDD XDDD PLS GIVE ME KARMA XDXDDDD HI GUYS MICHAEL P HERE TODAY WE'RE GONNA PLAY INNAPROPRIATE LOBBY NUMBER 2, IT'S CALLED.. OBBY FOR SUCC! I THINK THAT SUCC MEANS LIKE "CONGRATUALATE" IN SOME OTHER LANGUAGE OR SOMETHING I DUNNO, OK LET'S GO! UWIHGWEUQGU
		give_armour(-amount * 0.75)
	else:
		vars.health -= amount
	
	if vars.health <= 20:
		if !alarmed:
			util.playsfx("res://sound/player/alarm.wav")
			alarmed = true
	else:
		alarmed = false

func _physics_process(delta):
	if util.cheats:
		%body_collision.disabled = vars.noclip
		%fullbright.visible = vars.full_bright
	
	%flashlight.visible = vars.flashlight
		
	if vars.player_frozen:
		return

	if position.y < -1000:
		damage("crush", 100000000000)
	
	vars.direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("movement_backwards") - Input.get_action_strength("movement_forward")
	var h_input = Input.get_action_strength("movement_right") - Input.get_action_strength("movement_left")
	vars.camera_rotation.z = -h_input * 4
	vars.direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	# NOCLIP
	if vars.noclip && util.cheats:
		vars.movement = vars.direction * vars.ACCEL_DEFAULT * 2
		vars.gravity_vec.y = Input.get_action_strength("movement_jump") * 8 - Input.get_action_strength("movement_crouch") * 8

	# BASIC GRAVITY
	if !vars.noclip || !util.cheats:
		if is_on_floor():
			var fall = abs(vars.gravity_vec.y)
			vars.accel = vars.ACCEL_DEFAULT

			vars.gravity_vec = Vector3.ZERO

			if fall > 0.0:
				randomSFX("player/footsteps")

				var multi = randf_range(-1, 1)
				if multi == 0.0:
					multi = 1.0
					vars.camera_rotation.z = fall * multi

			if fall > 10.0:
				if fall > 10 && !fall >= vars.health:
					damage("fall", fall)
				elif fall >= vars.health:
					damage("crush", fall)

				fall = 0.0

			if Input.is_action_just_pressed("movement_jump") && vars.health > 0:
				randomSFX("player/footsteps")
				vars.gravity_vec.y = vars.jump
		else:
			vars.accel = vars.ACCEL_AIR

			vars.gravity_vec.y -= vars.gravity * delta
		
		# CEILING
		if is_on_ceiling():
			vars.gravity_vec = Vector3.DOWN * 1.0

	# CROUCHING
	if Input.is_action_pressed("movement_crouch") && vars.health > 0 || vars.health < 0:
		vars.speed = vars.SPEED_MIN
		vars.target_height = 1.0

	elif !Input.is_action_pressed("movement_crouch") && !%standup_ray.is_colliding():
		vars.speed = vars.SPEED_DEFAULT
		vars.target_height = 1.9

	# SPRINTING
	if Input.is_action_pressed("movement_sprint") && can_power() && vars.direction.length() > 0.1 && is_on_floor() && vars.target_height > 1.5:
		vars.speed = vars.SPEED_MAX
		vars.sprinting = true
	
	if !Input.is_action_pressed("movement_sprint") || vars.target_height < 1.5 || !can_power() || vars.direction.length() < 0.1 || vars.target_height < 1.5:
		vars.speed = vars.SPEED_DEFAULT
		vars.sprinting = false

	# FLASHLIGHT
	if Input.is_action_just_pressed("weapon_flashlight") && vars.health > 0 && can_power():
		vars.flashlight = !vars.flashlight
		util.playsfx("res://sound/player/flashlight.wav", 0, 0, self)

	elif Input.is_action_just_pressed("weapon_flashlight") && vars.health > 0 && !can_power():
		util.playsfx("res://sound/player/deny.wav", 0, 0, self)

	# FOOTSTEPS
	if is_on_floor():
		vars.footsteps_timer += 0.65 * delta
		if vars.footsteps_timer > 1.5 / vars.speed && velocity.length() > 0.5:
			vars.footsteps_timer = 0
			randomSFX("player/footsteps")

	# DEATH
	if vars.health <= 0:
		vars.direction = Vector3.ZERO
		
		$Head.position = Vector3.ZERO
		$HUD.visible = false
		
		vars.accel = vars.ACCEL_AIR
	
	vars.movement = vars.movement.lerp(vars.direction * vars.speed, vars.accel * delta)

	vars.gravity_vec.x = 0
	vars.gravity_vec.z = 0

	%body_collision.shape.height = lerp(%body_collision.shape.height, vars.target_height, 0.2)

	velocity = vars.movement + vars.gravity_vec
	move_and_slide()

	camera.fov = lerp(camera.fov, vars.camera_fov, 0.15)
	camera.rotation_degrees = camera.rotation_degrees.lerp(vars.camera_rotation, 0.05)
	camera.transform.origin = camera.transform.origin.lerp(vars.camera_translation, 0.05)
	vars.camera_translation = vars.camera_translation.lerp(Vector3.ZERO, 0.1)
	vars.camera_rotation = vars.camera_rotation.lerp(Vector3.ZERO, 0.1)


func power_tick():
	if vars.power_less:
		return

	vars.power_usage = 0
	
	if vars.sprinting:
		vars.power_usage += vars.SPRINT_USAGE
	
	if vars.flashlight:
		vars.power_usage += vars.FLASHLIGHT_USAGE


	if vars.power >= 100.0:
		if vars.power_shown:
			vars.power_shown = false
			%power_bar_anim.play("hide")

	if vars.power_usage <= 0.0 && vars.power < 100.0:
		if !vars.power_shown:
			vars.power_shown = true
			%power_bar_anim.play("show")
		vars.power += 1
	
	if vars.power_usage > 0.0:
		if !vars.power_shown:
			vars.power_shown = true
			%power_bar_anim.play("show")
		vars.power -= vars.power_usage
		vars.power = clamp(vars.power, 0.0, 100.0)
		
		if vars.power <= 0.0 && !vars.power_depleted:
			if vars.power_shown:
				%power_bar.modulate = Color(1.0, 0.0, 0.0)
			util.playsfx3D("res://sound/player/power_depleted.wav", 0.0, 1.0, 10.0, self)
			vars.power_depleted = true
			vars.flashlight = false
		
	if vars.power > 50.0:
		if vars.power_shown:
			%power_bar.modulate = Color(1.0, 1.0, 1.0)
		vars.power_depleted = false
	
	if vars.power > 100.0:
		vars.power = 100.0
