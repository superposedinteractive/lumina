extends lumina_entity

@export var targets : Array
@export var optional_name : Array

func _ready():
	for target in targets:
		target = get_node_or_null(target)

func trigger():
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
