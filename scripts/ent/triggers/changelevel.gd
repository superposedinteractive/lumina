extends Node

func _process(delta):
	if util.developer:
		get_child(1).visible = true
	else:
		get_child(1).visible = false

@export var target_map : String = ""

@export var discard_player : bool = false
@export var hide_hud : bool = false

@export var ply_rotation : Vector3 = Vector3(-1, -1, -1)
@export var ply_speed : Vector3 = Vector3(-1, -1, -1)

func _on_body_entered(body):
	if body.name == "Player" && util.player_node.vars.health > 0:
		util.load_map("res://maps/" + target_map + ".tscn", discard_player, hide_hud, ply_speed, ply_rotation)
