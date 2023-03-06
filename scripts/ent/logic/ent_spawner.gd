extends lumina_entity

@export var ent_name : String = "armour_small"
var ent : Node

func _ready():
	if ent_name == "" || ent_name == null || ResourceLoader.exists("res://prefabs/ent/" + ent_name + ".tscn") == false:
		error("Entity name is not set or does not exist")
		return
	
	msg("Ready, awaiting trigger")

func trigger():
	ent = util.load_asset("res://prefabs/ent/" + ent_name + ".tscn")
	add_child(ent)
	msg("Entity loaded")
