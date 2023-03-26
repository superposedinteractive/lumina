extends lumina_entity

@export var target : lumina_entity
@export var once : bool = false
@export var solid_to_player : bool = true

func _ready():
	if !target is lumina_entity:
		util.notif(str(self) + " Target isn't a lumina_entity or doesn't exist.")

	if solid_to_player:
		get_node("button").collision_layer = 1
		get_node("button").collision_mask = 1
	else:
		get_node("button").collision_layer = 2
		get_node("button").collision_mask = 2

func use():
	if !target is lumina_entity:
		util.notif(str(self) + " Target isn't a lumina_entity or doesn't exist.")
		return
	
	msg("used!")
	target.trigger()
	if once:
		queue_free()