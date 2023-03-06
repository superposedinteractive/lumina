extends lumina_entity

@export var target : lumina_entity

func _ready():
	if target == null:
		error("target is null")

func use():
	msg("used!")
	if target != null:
		target.trigger()
	else:
		util.notif(str(self) + " Target is null, not deleting because collisions.")
