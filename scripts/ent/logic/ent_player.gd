extends lumina_entity

@export var targets : Array
@export var optional_name : Array
@export var multiple : bool = false

var used = false

func _ready():
	for target in targets:
		target = get_node_or_null(target)

func trigger():
	if used:
		msg("used when multiple flag is off.")
		return
	
	msg("playing supported entities")
	var i : int = 0
	for target in targets:
		target = get_node_or_null(target)
		
		match target.get_class():
			"AnimationPlayer":
				target.play(optional_name[i])
			_:
				util.notif(str(self) + " " + str(target) + " isn't a supported entity or doesn't exist.")

		i += 1
	
	if !multiple:
		used = true
