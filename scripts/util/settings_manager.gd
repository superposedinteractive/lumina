extends Node

signal settings_changed

var _settings = {
	'window_w': -1,
	'window_h': -1,
	'windowed': false,
	'vsync': true,
	'glow': true,
	'volumetric_fog': true,
	'motion_blur': true
}

func _ready():
	
	_load()
	
func save_settings():
	_settings_changed()
	_save()

func _settings_changed():
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if get_setting('vsync') else DisplayServer.VSYNC_DISABLED)
	
	if get_setting("window_w") == -1 or get_setting("window_h") == -1:
		get_window().size = DisplayServer.screen_get_size()
	else:
		get_window().size = Vector2(get_setting('window_w'),get_setting('window_h'))
	get_window().content_scale_size = get_window().size

	get_window().mode = Window.MODE_WINDOWED
		
	await get_tree().process_frame
		
	if get_setting('windowed'):
		get_window().mode = Window.MODE_WINDOWED
	else:
		get_window().mode = Window.MODE_FULLSCREEN

	settings_changed.emit()
	
func set_setting(s: String, value: Variant):
	_settings[s] = value
	
func get_setting(s: String) -> Variant:
	return _settings[s]
	
func get_setting_or(s: String, default: Variant) -> Variant:
	if _settings.has(s):
		return _settings[s]
	return default

func _save():
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	var data = JSON.stringify(_settings)
	print(data)
	file.store_string(data)
	file.close()

func _load():
	var file = FileAccess.open("user://settings.save", FileAccess.READ)
	
	if file == null:
		print("Using default settings")
		_settings_changed()
		return
	
	
	var data = file.get_as_text()
	var json = JSON.parse_string(data)
	print(data)
	
	for key in json:
		_settings[key] = json[key]
			
	_settings_changed()
	
