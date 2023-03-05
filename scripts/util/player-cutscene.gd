extends AnimationPlayer

@export var anim_name : String = ""
@export var tp_target : NodePath

func _ready():
	while util.player_node == null:
		await get_tree().process_frame
	
	util.player_node.vars.player_frozen = true
	util.player_node.get_node("Head").get_node("Camera").current = false
	play(anim_name)
	
	await animation_finished
	
	util.player_node.get_node("Head").get_node("Camera").current = true
	util.player_node.global_transform = get_node(tp_target).global_transform
	util.player_node.vars.player_frozen = false
