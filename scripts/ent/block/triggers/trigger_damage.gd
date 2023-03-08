extends lumina_entity

@export var damage : int = 10
@export var type : String = "generic"

@export var interval : float = 1
@export var knockback : Vector3 = Vector3.ZERO

@onready var timer : Timer = Timer.new()

func _ready():
	add_child(timer)
	timer.wait_time = interval
	timer.one_shot = false

	timer.timeout.connect(_on_Timer_timeout)

func _on_body_entered(body):
	timer.start()

func _on_body_exited(body):
	timer.stop()

func _on_Timer_timeout():
	trigger()

func trigger():
	var bodies = $Area3D.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("damage"):
			body.damage(type, damage, knockback)
