extends Label

@export var shakeforce = 2
@onready var ogpos = position
@onready var ogrot = rotation
@onready var ogoffset = pivot_offset

func _process(delta):
	position = ogpos + Vector2(randf_range(-shakeforce, shakeforce), randf_range(-shakeforce, shakeforce))
	rotation_degrees = ogrot + randf_range(-shakeforce, shakeforce)
	pivot_offset = ogoffset + Vector2(randf_range(-shakeforce * 4, shakeforce * 4), randf_range(-shakeforce * 4, shakeforce * 4))

	%rgb.color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
