extends Node

func use():
	print("redirecting to " + get_parent().get_parent().name)
	get_parent().get_parent().use()
