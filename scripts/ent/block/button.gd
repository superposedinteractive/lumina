extends lumina_entity

@export var target : lumina_entity
@export var once : bool = false

func _ready():
	if !target is lumina_entity:
		util.notif(str(self) + " Target isn't a lumina_entity or doesn't exist.")

func use():
	if !target is lumina_entity:
		util.notif(str(self) + " Target isn't a lumina_entity or doesn't exist.")
		return
	
	msg("used!")
	target.trigger()
	if once:
		queue_free()