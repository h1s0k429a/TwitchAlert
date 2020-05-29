extends EditorPlugin
tool

const PLUGIN_NAME: String = "Twitch"

func enable_plugin() -> void:
	print(PLUGIN_NAME, " activated.")
	
func disable_plugin() -> void:
	print(PLUGIN_NAME, " deactivated.")
