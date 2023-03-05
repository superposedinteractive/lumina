extends MeshInstance3D

func _ready():
	rotation_degrees.y = 1
	rotation_degrees.x = 1
	rotation_degrees.z = 1

func _process(delta):
	rotation_degrees.x += delta * 100
	rotation_degrees.y += delta * 100
	rotation_degrees.z += delta * 100
