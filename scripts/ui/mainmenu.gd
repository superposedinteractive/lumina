extends Control

var chapters = {
	"Welcome": "welcome"
}

func paused():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func mouse_entered():
	util.playsfx("res://sound/ui/hover.wav")

func _ready():
	if %chapter_select != null && %chapter_list != null && %chapter_template != null:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		%chapter_select.visible = false

		for item in get_node("menubuttons").get_children():
			if item is Button:
				item.connect("mouse_entered", mouse_entered)
	
		for chapter in chapters.keys():
			var button = %chapter_template.duplicate()
			button.get_node("Button").text = chapter
			button.get_node("Button").pressed.connect(chapter_pressed.bind(chapter))
			button.visible = true
			%chapter_list.add_child(button)

func newgame_pressed():
	util.playsfx("res://sound/ui/click.wav")

	%chapter_select.popup_centered(Vector2(450, 150))

func quit_pressed():
	get_tree().quit()

func return_menu():
	util.playsfx("res://sound/ui/click.wav")
	util.load_map("res://scenes/mainmenu.tscn", true, true)
	
	while !util.has_node("Player"):
		await get_tree().process_frame
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	util.player_node.queue_free()

func credits_pressed():
	util.playsfx("res://sound/ui/click.wav")
	util.load_map("res://scenes/credits.tscn", true, true)
	
	while !util.has_node("Player"):
		await get_tree().process_frame
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	util.player_node.process_mode = Node.PROCESS_MODE_DISABLED

func chapter_pressed(chapter):
	util.playsfx("res://sound/ui/click.wav")
	
	var hidehud = false

	match chapter:
		"Chapter names to hide the hud":
			hidehud = true
		_:
			hidehud = false

	%chapter_select.hide()
	visible = false

	util.load_map("res://maps/" + chapters[chapter] + ".tscn", true, hidehud)

func resume_pressed():
	util.playsfx("res://sound/ui/click.wav")

	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false

func options_pressed():
	util.playsfx("res://sound/ui/click.wav")

	var settings = load("res://scenes/settings.tscn").instantiate()
	add_child(settings)
	settings.popup_centered(Vector2(600, 500))


func readmebutton_pressed():
	OS.alert("Welcome beta tester!\n\nCongratulations on being accepted to test an early build of Radiance!\nKeep in mind that this is a very early build, and there are many bugs and possibly unfinished maps.\n\nIf you find any bugs, please report them to our discord under the \"BETA\" category in the #radiance channel!\n\nKNOWN ISSUES:\n- Physics objects may sometimes clip through the floor if falling with funny speeds.\n- Too many bullet holes may cause the game to crash.\n- Saves are sometimes inaccurate.\n\nOn this build, you're allowed to:\n- Publish screenshots and videos of the game, publicly or privately.\n\nBut you're strictly prohibited to:\n- Leak any build of the game available to you.\n\nIf you're found breaking any of these rules, you will be banned from the beta program, and your beta access will be revoked.\n\nOther than that, thank you for testing Radiance!", "Welcome to the Radiance beta!")
