extends lumina_entity

@export var power : bool = true

func _on_body_entered(body):
	if body.name == "Player" && util.player_node.vars.health > 0:
		util.player_node.vars.power_less = !power
