extends lumina_entity

@export var target : lumina_entity

func _ready():
	if target == null:
		error("target is null")

func use():
	msg("used!")
	target.trigger()
