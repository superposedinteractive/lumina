extends Node3D
class_name weapon

enum wep_state {
	IDLE,
	FIRING_PRIMARY,
	FIRING_SECONDARY,
	RELOADING
}

@export var display_name : String = "???"

@export var damage : int = 1
@export var base_accuracy : float = 0.1
@export var recoil : float = 0.1

@export var max_range : float = 1
@export var clip_size : int = 10

@export var bullets : int = 1

@export var reload_time : float = 1
@export var fire_rate : float = 1
@export var fire_rate_secondary : float = 1
@export var automatic : bool = false

@export var ammo : int = 10
@export var secondary_ammo : int = 3

@export var fire_sound : String = ""
@export var fire_sound_secondary : String = ""
@export var reload_sound : String = ""

var state : wep_state = wep_state.IDLE
var fire_timer : float = 0
var reload_timer : float = 0

var bob_target : Vector3 = Vector3.ZERO
var bob_rotation : Vector3 = Vector3.ZERO
var view_sway : Vector3 = Vector3.ZERO

var hidden = true

var clip : int = 0

@onready var model : Node3D = load("res://models/weapons/" + name + ".glb").instantiate()
@onready var model_anim : AnimationPlayer = model.get_node("AnimationPlayer")

func _ready():
	model.name = "model"
	model_anim.playback_default_blend_time = 0.1
	add_child(model)

func _input(event):
	if event.is_action_pressed("weapon_fire1"):
		if state == wep_state.IDLE:
			state = wep_state.FIRING_PRIMARY
			fire_timer = fire_rate
	elif event.is_action_pressed("weapon_fire2"):
		if state == wep_state.IDLE:
			fire_timer = fire_rate_secondary
			state = wep_state.FIRING_SECONDARY
	elif event.is_action_pressed("weapon_reload"):
		if state == wep_state.IDLE:
			state = wep_state.RELOADING
			reload_timer = 0

func _process(delta):
	visible = !util.player_node.vars.health <= 0 && util.player_node.vars.weapon_active == name
	if !visible:
		hidden = true
		return

	var plyspeed = util.player_node.vars.movement.length()
	var time = Time.get_ticks_msec() / 1000.0

	bob_rotation = Vector3.ZERO
	bob_target.z = 0.1

	if !util.player_node.is_on_floor():
		bob_target = Vector3(0, util.player_node.vars.gravity_vec.y * 0.01, 0.1)
	else:
		if plyspeed > 7:
			bob_target.x = sin(time * 10) * 0.1 * clamp(plyspeed / 15, 0, 1)
			bob_target.y = -abs(sin(time * 10) * 0.1 * clamp(plyspeed / 15, 0, 1)) - 0.1
		else:
			bob_target.x = sin(time * 3) * 0.05 * clamp(plyspeed / 15, 0, 1)
			bob_target.y = (sin(time * 6) * 0.05 * clamp(plyspeed / 15, 0, 1))

	if hidden:
		bob_rotation.x = 0
		bob_rotation.z = 90
		bob_rotation.y = -10
		bob_target.x = -0.5
		bob_target.y = -0.5
		bob_target.z = 0.1
		
		model.position = bob_target
		model.rotation_degrees = bob_rotation
		hidden = false
		
		model.position = bob_target
		model.rotation_degrees = bob_rotation
		hidden = false

	model.position = lerp(model.position, bob_target + view_sway, 0.1)
	model.rotation_degrees = lerp(model.rotation_degrees, bob_rotation, 0.1)

	view_sway = Vector3.ZERO

	if state == wep_state.FIRING_PRIMARY:
		fire_timer += delta

		if fire_timer >= fire_rate:
			if Input.is_action_pressed("weapon_fire1"):
				if clip <= 0 && clip_size > 0:
					state = wep_state.RELOADING
					reload_timer = 0
					return

				if clip_size > 0:
					if clip > 0:
						clip -= 1

						var bullet_collision : bool = false

						util.player_node.vars.camera_rotation += Vector3(recoil, randf_range(-1, 1) * recoil, 0)

						for i in range(bullets):
							var bullet = util.hitscan_bullet(util.player_node, damage, max_range, base_accuracy)

							if bullet.is_colliding():
								bullet_collision = true

						if bullet_collision:
							fire("primary")
						else:
							fire("primary_miss")
				else:
					var bullet = util.hitscan_bullet(util.player_node, damage, max_range, base_accuracy)
					util.player_node.vars.camera_rotation += Vector3(recoil, randf_range(-1, 1) * recoil, 0)

					if bullet.is_colliding():
						fire("primary")
					else:
						fire("primary_miss")
				if automatic:
					fire_timer = 0
			else:
				state = wep_state.IDLE
				
	elif state == wep_state.FIRING_SECONDARY:
		fire_timer += delta
		if fire_timer >= fire_rate_secondary:
			if Input.is_action_pressed("weapon_fire2"):
				if clip_size > 0:
					if secondary_ammo > 0:
						util.player_node.vars.camera_rotation += Vector3(recoil * 2, randf_range(-1, 1) * recoil * 2, 0)
						
						secondary_ammo -= 1
						fire("secondary")
				else:
					if secondary_ammo < -1:
						util.player_node.vars.camera_rotation += Vector3(recoil * 2, randf_range(-1, 1) * recoil * 2, 0)

						fire("secondary")
				if automatic:
					fire_timer = 0
			else:
				state = wep_state.IDLE

	elif state == wep_state.RELOADING:
		if clip >= clip_size:
			state = wep_state.IDLE
			return
		
		if ammo <= 0:
			state = wep_state.IDLE
			return

		reload_timer += delta
		if reload_timer >= reload_time:

			state = wep_state.IDLE
			if (ammo + clip) > clip_size:
				clip = clip_size
				ammo -= clip_size
			else:
				clip += ammo
				ammo = 0

			if Input.is_action_pressed("weapon_fire1"):
				state = wep_state.FIRING_PRIMARY
				fire_timer = fire_rate
			elif Input.is_action_pressed("weapon_fire2"):
				state = wep_state.FIRING_SECONDARY
				fire_timer = fire_rate_secondary
	elif state == wep_state.IDLE:
		if model_anim.current_animation != "idle":
			model_anim.play("idle")


func fire(type : String):
	if type == "primary":
		model_anim.stop()
		model_anim.play("attack")
		util.playsfx3D(fire_sound, -20.0, 1.0, 10.0, self)
	elif type == "primary_miss":
		if model_anim.has_animation("attack_miss"):
			model_anim.stop()
			model_anim.play("attack_miss")
			util.playsfx3D(fire_sound, -20.0, 1.0, 10.0, self)
		else:
			fire("primary")
	elif type == "secondary":
		model_anim.stop()
		model_anim.play("attack2")
		util.playsfx3D(fire_sound_secondary, 0.0, 1.0, 10.0, self)
	elif type == "secondary_miss":
		model_anim.stop()
		model_anim.play("attack2_miss")
		util.playsfx3D(fire_sound_secondary, 0.0, 1.0, 10.0, self)
