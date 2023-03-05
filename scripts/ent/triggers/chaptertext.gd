extends Node

func _process(delta):
	if util.developer:
		get_child(1).visible = true
	else:
		get_child(1).visible = false

@export var text = "CHAPTER"

func _on_body_entered(body):
	if body.name == "Player":
		util.player_node.chapter_text(text)
		queue_free()
