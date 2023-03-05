extends Window

const KB_INPUTS = {
	"movement_forward": "Walk Forward",
	"movement_backwards": "Walk Backward",
	"movement_left": "Strafe Left",
	"movement_right": "Strafe Right",
	"movement_jump": "Jump",
	"movement_sprint": "Sprint",
	"movement_crouch": "Crouch",

	"weapon_fire1": "Fire Primary",
	"weapon_fire2": "Fire Secondary",
	"weapon_reload": "Weapon Reload",
	"weapon_next": "Next Weapon",
	"weapon_prev": "Previous Weapon",

	"weapon_flashlight": "Flashlight",

	"ui_zoom": "Zoom",
	"ui_use": "Use"
}

const RESOLUTIONS = {
	"Monitor's Native" : Vector2(0, 0),
	"1920x1080" : Vector2(1920, 1080),
	"1440x1080" : Vector2(1440, 1080),
	"1600x900" : Vector2(1600, 900),
	"1600x1200" : Vector2(1600, 1200),
	"1280x720" : Vector2(1280, 720),
	"1280x1024" : Vector2(1280, 1024),
	"1024x768" : Vector2(1024, 768),
	"800x600" : Vector2(800, 600),
	"640x480" : Vector2(640, 480),
	"320x240" : Vector2(320, 240)
}

var bind : String = ""

func _input(event):
	if event is InputEventKey && %awaiting_input.visible && bind != "":
		if event.is_action("ui_cancel"):
			%awaiting_input.visible = false
			return

		InputMap.action_erase_events(bind)
		InputMap.action_add_event(bind, event)
		%keyboard_list.get_node(bind).get_node("input_bind").text = InputMap.action_get_events(bind)[0].as_text()
		%awaiting_input.visible = false

func _ready():
	%keyboard_prefab.visible = false
	for key in KB_INPUTS:
		var prefab = %keyboard_prefab.duplicate()
		prefab.visible = true
		prefab.get_node("input_name").text = KB_INPUTS[key]
		prefab.get_node("input_bind").text = InputMap.action_get_events(key)[0].as_text()
		prefab.get_node("input_bind").pressed.connect(bind_key.bind(prefab))
		prefab.name = key
		%keyboard_list.add_child(prefab)
	

	%resolutions_list.clear()
	for key in RESOLUTIONS:
		%resolutions_list.add_item(key)
		

func bind_key(key):
	bind = key.name
	%awaiting_input.visible = true

func ok_pressed():
	apply_pressed()
	queue_free()

func apply_pressed():
	pass # Replace with function body.

func cancel_pressed():
	queue_free()
