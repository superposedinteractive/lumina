extends Node

@onready var args = OS.get_cmdline_args()

var player_node : Node = null

var developer = false
var cheats = false

@export var player_save : Resource
@export var player_pos : Vector3 = Vector3.ZERO

var loading_screen : Node
var subtitles : Node

var subtitles_json : Dictionary

var map : Node = null

func _ready():
	for arg in args:
		match arg:
			"--dev":
				print("developer mode on")
				developer = true
			"--cheats":
				print("cheats on")
				cheats = true
				add_child(load("res://scenes/cheats.tscn").instantiate())

	var jsonfile = FileAccess.open("res://cfg/subtitles.json", FileAccess.READ)

	subtitles_json = JSON.parse_string(jsonfile.get_as_text())

	process_mode = Node.PROCESS_MODE_ALWAYS

	loading_screen = load("res://scenes/loading.tscn").instantiate()
	subtitles = load("res://scenes/subtitles.tscn").instantiate()

	add_child(loading_screen)
	add_child(subtitles)

	loading_screen.visible = false

	var text : String
	var file : FileAccess = FileAccess.open("user://gamestatus.dat", FileAccess.READ)
	if file:
		text = file.get_as_text()
		file = null

	await get_tree().create_timer(3).timeout

	if text == "1":
		get_tree().change_scene_to_file("res://scenes/congrats1.tscn")
	elif text == "2":
		get_tree().change_scene_to_file("res://scenes/congrats2.tscn")
	elif text == "3":
		get_tree().change_scene_to_file("res://scenes/congrats3.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func reload_subtitles():
	print("reloading subtitles...")
	var jsonfile = FileAccess.open("res://cfg/subtitles.json", FileAccess.READ)
	subtitles_json = JSON.parse_string(jsonfile.get_as_text())

func _process(_delta):
	if player_node != null:
		if player_node.name != "Player":
			player_node.name = "Player"
	
	get_tree().root.move_child(self, get_tree().root.get_child_count() - 1)

func _input(event):
	if Input.is_key_pressed(KEY_F11):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_key_pressed(KEY_F5):
		print("reloading subtitles")
		reload_subtitles()

func _notification(what):
	if map == null:
		return

	if what == Node.NOTIFICATION_INTERNAL_PROCESS:
		for child in map.get_children():
			if child is AudioStreamPlayer || child is AudioStreamPlayer3D:
				if child.is_playing():
					print("playing sound")

					var distance = player_node.position.distance_to(child.position)

					if child.stream.get_path() in subtitles_json && (distance <= child.max_distance || child.max_distance == 0.0):
						show_subtitle(subtitles_json[child.stream.get_path()], child.stream.get_length())

func crash(reason):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	OS.alert("Something wwong has happenyed t-to the x3 game, and that caused i-it t-to cwash. This m-might just *whispers to self* be a test in a contwowwed enviwonment, howevew, if nyot, pwease wepowt i-it t-to youw wocaw Supewposed empwoyee.\n\nerr_reason: " + reason, "Engine error!")
	OS.crash(reason)

func kill_node(ent):
	if ent is Array:
		for e in ent:
			e.queue_free()
	else:
		ent.queue_free()

func playsfx(sfx: String, volume = 0.0, pitch = 1.0, parent : Node = null, loop : bool = false):
	var player = AudioStreamPlayer.new()

	if parent != null:
		parent.add_child(player)
	else:
		add_child(player)

	player.name = sfx

	player.finished.connect(kill_node.bind(player))

	player.stream = load(sfx)
	player.volume_db = volume
	player.pitch_scale = pitch

	if sfx in subtitles_json:
		show_subtitle(subtitles_json[sfx], player.stream.get_length())

	player.play()

func playsfx3D(sfx : String = "", volume : float = 0.0, pitch : float = 1.0, range : float = 10.0, parent : Node = null, loop : bool = false, position : Vector3 = Vector3.ZERO):
	var player = AudioStreamPlayer3D.new()

	parent.add_child(player)
	player.position = position

	player.finished.connect(kill_node.bind(player))

	player.stream = load(sfx)
	player.volume_db = volume
	player.pitch_scale = pitch
	player.max_distance = range

	player.name = sfx.replace("res://sound/", "")

	var distance = player_node.position.distance_to(player.position)

	if sfx in subtitles_json && (distance <= player.max_distance || player.max_distance == 0.0):
		show_subtitle(subtitles_json[sfx], player.stream.get_length())

	player.play()

func sfxlength(sfx : String):
	var player = AudioStreamPlayer.new()
	player.stream = load(sfx)
	player.queue_free()
	return player.stream.get_length()

# saving and loading

func save_game(save_name : String):
	if player_save == null:
		crash("player_save invalid")
	var save_file = FileAccess.open(save_name, FileAccess.WRITE)
	save_file.store_buffer(player_save.save_to_buffer())

# map loading

func load_map(map_name : String, discard_player : bool = false, hide_hud : bool = false, player_speed : Vector3 = Vector3(-1, -1, -1), player_angle : Vector3 = Vector3(-1, -1, -1)):
	loading_screen.visible = true

	get_tree().paused = true
	get_tree().root.move_child(loading_screen, get_tree().root.get_child_count() - 1)

	if player_node != null:
		player_node.get_node("HUD").visible = false

	await get_tree().process_frame
	await get_tree().process_frame

	if map != null:
		map.queue_free()
		map = null
	
	if get_tree().root.has_node("bgmap"):
		get_tree().root.get_node("bgmap").queue_free()
		# just a little hack to make sure the bgmap is gone

	map = load(map_name).instantiate()

	get_tree().root.add_child(map)
	
	if map.has_node("Player"):
		map.get_node("Player").queue_free()

	# lol
	for child in map.get_children():
		if child is Decal:
			child.cull_mask &= ~(1 << 19)
		else:
			for c in child.get_children():
				if c is Decal:
					c.cull_mask &= ~(1 << 19)
				else:
					for cc in c.get_children():
						if cc is Decal:
							cc.cull_mask &= ~(1 << 19)
						else:
							for ccc in cc.get_children():
								if ccc is Decal:
									ccc.cull_mask &= ~(1 << 19)
								else:
									for cccc in ccc.get_children():
										if cccc is Decal:
											cccc.cull_mask &= ~(1 << 19)

	if player_node == null || discard_player:
		print("player_node null or discard_player true. creating new player")
	
		if player_node != null:
			player_node.queue_free()
	
		player_node = load("res://prefabs/ent/player.tscn").instantiate()

		player_node.process_mode = Node.PROCESS_MODE_PAUSABLE
		
		add_child(player_node)

	if hide_hud:
		player_node.get_node("HUD").visible = false

	if map.has_node("player_spawn"):
		player_node.position = map.get_node("player_spawn").position + Vector3(0, 0.95, 0)
	else:
		print("no player_spawn node found, defaulting to map origin")
		map.position = Vector3(0, 0.95, 0)
	
	if player_speed != Vector3(-1, -1, -1):
		player_node.vars.movement = Vector3(player_speed.x, 0, player_speed.z)
		player_node.vars.gravity_vec.y = player_speed.y

	if player_angle != Vector3(-1, -1, -1):
		player_node.rotation_degrees = Vector3(0, player_angle.y, 0)
		player_node.get_node("Head").rotation_degrees = Vector3(player_angle.x, 0, 0)

	if !hide_hud:
		player_node.get_node("HUD").visible = true
	loading_screen.visible = false

	get_tree().paused = false

	return "done"

# subtitles

func show_subtitle(text : String, duration : float = 3.0):
	var sub = subtitles.get_node("Panel").get_node("VBoxContainer").get_node("Subtitle").duplicate()

	subtitles.get_node("Panel").get_node("VBoxContainer").add_child(sub)

	sub.visible = true

	sub.get_node("subtitle").text = text
	sub.get_node("subtitle").get_node("AnimationPlayer").play("show")

	var timer = Timer.new()

	sub.add_child(timer)

	timer.one_shot = true
	timer.wait_time = duration + 0.5

	timer.timeout.connect(hide_subtitle.bind(sub))

	timer.start()

func hide_subtitle(sub : Node):
	sub.get_node("subtitle").get_node("AnimationPlayer").play("hide")

	await get_tree().create_timer(0.2).timeout

	sub.queue_free()

# bullets
func hitscan_bullet(attacker : Node, damage : int, range : float, spread : float, bullet_hit_sound : String = "res://sound/player/weapon/bullet/impact/1.wav"):
	var ray = RayCast3D.new()

	ray.add_exception(attacker)

	if attacker.get_node("Head"):
		attacker.get_node("Head").add_child(ray)
	else:
		attacker.add_child(ray)
	
	ray.target_position = Vector3(0, 0, -range)
	ray.target_position += Vector3(randf_range(-spread, spread), randf_range(-spread, spread), randf_range(-spread, spread))

	ray.force_raycast_update()

	if bullet_hit_sound != "" && ray.is_colliding():
		playsfx3D(bullet_hit_sound, 0.0, 0.0, 10.0, map, false, ray.get_collision_point())

	var self_world_transform = ray.global_transform
	ray.get_parent().remove_child(ray)
	map.add_child(ray)
	ray.global_transform = self_world_transform

	var bullethole = Decal.new()

	if !ray.is_colliding():
		bullethole.queue_free()

	if ray.is_colliding():
		# why fucking bits, godoooooooooooooot
		bullethole.cull_mask &= ~(1 << 19)
		bullethole.texture_albedo = load("res://mat/decals/world/bullethole.png")
		bullethole.size = Vector3(0.15, 0.15, 0.15)
		bullethole.rotation = ray.get_collision_normal() + bullethole.to_local(Vector3(0, randf_range(0, 360), 0))
		bullethole.position = ray.get_collider().to_local(ray.get_collision_point())
		
		ray.get_collider().add_child(bullethole)

		if ray.get_collider() is RigidBody3D:
			print("applying " + str(damage) + " impulse to " + str(ray.get_collider()))
			ray.get_collider().apply_impulse(ray.get_collision_normal() * -damage, ray.get_collider().to_local(ray.get_collision_point()))

		var hit = ray.get_collider().get_parent()
		if hit.has_method("damage"):
			hit.take_damage(damage, attacker)
	
	var timer = Timer.new()
	ray.add_child(timer)
	timer.one_shot = true
	timer.wait_time = 2
	timer.timeout.connect(kill_node.bind(ray))
	timer.start()

	return ray
