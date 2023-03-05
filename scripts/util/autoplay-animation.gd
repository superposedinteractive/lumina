extends AnimationPlayer

@export var anim_name = ""

func _ready():
	print(str(self) + " playing " + anim_name)
	play(anim_name)
