extends lumina_entity

@export var target : lumina_entity
@export var flag : String = ""
@export var value : Array

func _ready():
	if flag == null || flag == "":
		error("Flag is empty")
	
	if value.size() != 1:
		error("value cannot be bigger or smaller than 0, it's to allow types.")

func trigger():
	msg("setting " + flag + " to " + str(value[0]))
	target.set(flag, value[0])
