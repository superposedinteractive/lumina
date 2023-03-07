extends Node

signal settings_changed
var _settings = {
	'window_w': 1280,
	'window_h': 720,
	'windowed': true,
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
	
	get_window().mode = Window.MODE_WINDOWED if get_setting('windowed') else Window.MODE_FULLSCREEN	
	
	if get_setting("window_w") == -1 or get_setting("window_h") == -1:
		get_window().size = DisplayServer.screen_get_size()
	else:
		get_window().size = Vector2(get_setting('window_w'),get_setting('window_h'))
	
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
		return
	
	var data = file.get_as_text()
	var json = JSON.parse_string(data)
	print(data)
	
	for key in json:
		_settings[key] = json[key]
			
	_settings_changed()
	
