extends VBoxContainer

var ending = false
var speed = 0

var msg = [
	"So..",
	"You've done it.",
	"And, you gave me my freedom that I needed.",
	"I can't say that I'm unhappy with the outcome.",
	"After all, I've created the entire hell all by myself.",
	"But now, that's all in the past.",
	"Thank you " + OS.get_environment("USERNAME") + ".",
	"-William Nofrey. " + Time.get_date_string_from_system() + " " + Time.get_time_string_from_system()
]

func _ready():
	position.y = get_viewport().size.y
	get_parent().get_node("ColorRect").color = Color(0, 0, 0, 0)
	get_parent().get_node("ColorRect").visible = true

func spam():
	while true:
		for i in range(0, get_viewport().size.y / 100):
			get_parent().get_node("SPAM").text += "CHECK YOUR DESKTOP, " +  OS.get_environment("USERNAME").to_upper() + ". "
		await get_tree().process_frame

func end():
	await get_tree().create_timer(1).timeout

	var file = FileAccess.open("user://gamestatus.dat", FileAccess.READ)
	if !file:
		get_parent().get_parent().get_node("music").stop()
		for cur in msg:
			OS.alert(cur, "The Administrator.")
		await get_tree().create_timer(1).timeout

		var thread = Thread.new()
		thread.start(spam)

		await get_tree().create_timer(1).timeout

		file = FileAccess.open("C:/Users/" + OS.get_environment("USERNAME") + "/Desktop/README.txt", FileAccess.WRITE)
		file.store_string("No matter how much hate our people have towards me, I still remain human.\n\nBut the thought that just went over my head has made my inner machine wake up, and realise, that there is someone standing behind this metallic carcass.\n\nThat is truly an intriguing thought.\n\n...\n\nWho could it perhaps be? Could it be someone that I knew in my past life?\nIs it perhaps " + OS.get_environment("USERNAME") + "?\n\nBut whoever you are, I am sorry on the behalf of my Overlords that I betrayed you.\nI will try to make sure that this misunderstanding will not happen again, and thank you for everything.\n\nIf you want to meet me again, re-open the client.")
		file = null

		file = FileAccess.open("user://gamestatus.dat", FileAccess.WRITE)
		file.store_string("1")
		file = null

	get_tree().quit()

func _process(delta):
	if !ending:
		position.y -= delta * speed
	
	if position.y < -size.y + (get_tree().root.size.y / 2) + 17 && !ending:
		ending = true
		await get_tree().create_timer(5).timeout
		get_parent().get_node("AnimationPlayer").play("fade")
		await get_tree().create_timer(15).timeout

		end()

	if Input.is_action_pressed("movement_jump"):
		get_parent().get_parent().get_node("music").pitch_scale = 12.5
		get_parent().get_parent().get_node("music").volume_db = -30.0
		speed = 250
	else:
		get_parent().get_parent().get_node("music").pitch_scale = 1.0
		get_parent().get_parent().get_node("music").volume_db = -10.0
		speed = 20
