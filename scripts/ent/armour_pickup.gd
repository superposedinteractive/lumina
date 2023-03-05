extends RigidBody3D

@export var amount : int = 5

func touch(body):
	if body.has_method("give_armour") && body.vars.armour < 100:
		body.give_armour(amount)
		queue_free()
