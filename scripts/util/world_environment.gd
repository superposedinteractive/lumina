extends WorldEnvironment


func _ready():
	change_environment()
	SettingsManager.settings_changed.connect(on_settings_changed)

func on_settings_changed():
	change_environment()

func change_environment():
	environment.glow_enabled = SettingsManager.get_setting('glow')
	environment.volumetric_fog_enabled = SettingsManager.get_setting('volumetric_fog')
