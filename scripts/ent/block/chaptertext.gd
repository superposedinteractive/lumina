extends lumina_entity

@export var text = "CHAPTER"

func _on_body_entered(body):
	if body.has_method("get_lumina_class"):
		if body.get_lumina_class() == "lumina_player":
			trigger()

func trigger():
	util.player_node.chapter_text(text)
	kill()
