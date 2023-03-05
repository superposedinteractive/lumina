extends Control

func _physics_process(delta):
	%debug.text = "FPS: " + str(Engine.get_frames_per_second())
