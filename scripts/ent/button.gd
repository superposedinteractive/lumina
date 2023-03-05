extends Node

func _process(delta):
	if util.developer:
		get_child(0).visible = true
	else:
		get_child(0).visible = false

func use():
	print("i got used")
	util.playsfx("res://sound/vo/my_name_is_important.ogg")
