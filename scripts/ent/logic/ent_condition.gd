extends lumina_entity

@export var condition : bool = false
@export var target : lumina_entity
@export var else_target : lumina_entity

func trigger():
	if target == null:
			util.notif(str(self) + " " + str(target) + " isn't a lumina_entity or doesn't exist.")
			return
	
	if target is lumina_entity:
		if condition:
			msg("Condition satisfied!")
			target.trigger()
		else:
			msg("Condition not satisfied!")
			if else_target is lumina_entity:
				msg("Triggering else")
				else_target.trigger()
	else:
		util.notif(str(self) + " " + str(target) + " isn't a lumina_entity or doesn't exist.")
		return
