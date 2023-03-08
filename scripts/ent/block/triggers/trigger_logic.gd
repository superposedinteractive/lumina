extends lumina_entity

@export var target : lumina_entity
@export var multiple : bool = false
@export var disabled : bool = false

func _ready():
	if target == null:
		error("Target is null")

func _on_body_entered(body):
	if body.has_method("get_lumina_class") && !disabled:
		if body.get_lumina_class() == "lumina_player":
			trigger()

func trigger():
	msg("Triggering " + str(target))
	target.trigger()
	if !multiple:
		kill()
