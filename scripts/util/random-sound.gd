extends Node3D

@export var is_2d : bool = false

@export var min_time : float = 10.0
@export var max_time : float = 40.0

@export var sounds : Array = []

var timer : Timer

var time : float
var sound : String

var last_sound : int

func _ready():
	time = randf_range(min_time, max_time)

	timer = Timer.new()

	add_child(timer)

	timer.timeout.connect(timeout)

	timer.wait_time = time
	timer.one_shot = true
	timer.start()

func timeout():
	var index : int = randi_range(0, sounds.size() - 1)

	if index == last_sound:
		index = (index + 1) % sounds.size()

	time = randf_range(min_time, max_time)
	sound = sounds[randi_range(0, sounds.size() - 1)]

	await get_tree().create_timer(time).timeout
	if is_2d:
		util.playsfx(sound, 0.0, 0.0, self)
	else:
		util.playsfx3D(sound, 0.0, 0.0, 10.0, self)
	
	last_sound = index

	timer.wait_time = time
	timer.start()
