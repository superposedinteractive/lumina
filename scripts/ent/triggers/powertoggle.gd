extends Node3D

func _process(delta):
	if util.developer:
		get_child(1).visible = true
	else:
		get_child(1).visible = false

@export var power : bool = true

func _on_body_entered(body):
	if body.name == "Player" && util.player_node.vars.health > 0:
		util.player_node.vars.power_less = !power
