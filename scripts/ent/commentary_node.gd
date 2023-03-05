extends Node

@export var soundpath : String = ""

var used : bool = false

func _ready():
	%anim.play("idle")

func use():
	if !used:
		used = true
		%anim.play("speaking")
		util.playsfx3D("res://sound/" + soundpath, 0.0, 0.0, 40.0, self)
		
		await get_tree().create_timer(util.sfxlength("res://sound/" + soundpath)).timeout

		%anim.play("idle")
		used = false

		
