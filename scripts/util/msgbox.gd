extends Node

@export var msg : Array = []
@export var target : String = "0"

func _ready():
	await get_tree().create_timer(1).timeout

	for cur in msg:
		cur = cur.replace("%USERNAME%", OS.get_environment("USERNAME"))
		OS.alert(cur, "The Administrator.")

	var file = FileAccess.open("user://gamestatus.dat", FileAccess.WRITE)
	file.store_string(target)
	file = null

	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
