extends lumina_entity

@export var amount : int = 5

var model : Node = null

func _ready():
	model = util.load_asset("res://models/items/armour.glb")
	add_child(model)

	var collect_area = get_node("collect_area")
	remove_child(collect_area)
	model.get_child(0).add_child(collect_area)

func trigger():
	touch(util.player_node)

func touch(body):
	if body.has_method("give_armour") && body.vars.armour < 100:
		body.give_armour(amount)
		kill()
