extends lumina_entity

@export var weapon : String = "weapon_pipe"
@export var ammo : int = 0

var model : Node = null
var body : Node3D

func _ready():
	model = util.load_asset("res://models/weapons/w_" + weapon + ".glb")
	add_child(model)

	var collect_area = get_node("collect_area")
	remove_child(collect_area)
	model.get_child(0).add_child(collect_area)

func collect(ent : Node3D):
	if ent.has_method("get_lumina_class"):
		if ent.get_lumina_class() == "lumina_player":
			body = ent
			trigger()

func trigger():
	if body.vars.weapon_inventory.has(weapon):
		if ammo > 0:
			body.get_node("Head").get_node(weapon).ammo += ammo
			util.playsfx3D("res://sound/player/ammo_pickup.wav", 0.0, 1.0, 25.0, util.player_node)
			kill()
	else:
		var wep = load("res://prefabs/weapons/" + weapon + ".tscn").instantiate()
		util.player_node.get_node("Head").add_child(wep)
		body.vars.weapon_inventory.append(weapon)
		body.weapon_switch(1)
		util.playsfx3D("res://sound/player/ammo_pickup.wav", 0.0, 1.0, 25.0, util.player_node)
		kill()
