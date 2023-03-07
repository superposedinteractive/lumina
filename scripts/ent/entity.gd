extends Node

class_name lumina_entity

func _process(delta):
	if get_node_or_null("dev") != null:
			get_node("dev").visible = util.developer

func kill():
	print("[" + str(self) + "] Bye bye")
	queue_free()

func trigger():
	msg("UNIMPLEMENTED TRIGGER FUNCTION")

func error(msg):
	util.notif("Something has gone wrong in " + str(self) + "\n" + msg)
	print("[" + str(self) + "] ERROR: " + msg + "! Killing self.")
	kill()

func msg(msg):
	print("[" + str(self) + "] " + str(msg))
