extends Node

onready var panel			: Panel = $PanelContainer/Panel
onready var panel_container	: PanelContainer = $PanelContainer
onready var name_label		: Label = $PanelContainer/Panel/NameLabel
onready var text_label		: Label = $PanelContainer/Panel/TextLabel
onready var close_button	: TextureButton = $PanelContainer/Panel/CloseButton
onready var sound_player	: AudioStreamPlayer = $SoundPlayer
onready var twitch			: TwitchChat = $TwitchChat

var sounds: Dictionary = {
	"tone" : load("res://sounds/tone.wav"),
	"honk" : load("res://sounds/honk.wav")
}

func _ready():
	panel.connect("gui_input", self, "_on_gui_input")
	close_button.connect("pressed", self, "_on_close_pressed")
	twitch.connect("user_message", self, "_on_user_message")
	twitch.start_with("res://twitch.cfg")

func _on_user_message(user: TwitchUser, message: String) -> void:
	var sound_name:String = "tone"
	if (message[0] == "!"):
		var position: int = message.find(" ")
		if (position < 0): position = message.length()
		sound_name = message.substr(1, position - 1).to_lower()
		message = message.substr(position + 1)
	if (sounds.has(sound_name)):
		sound_player.stream = sounds[sound_name]
		sound_player.play()
	name_label.self_modulate = user.get_color()
	name_label.text = user.get_display_name()
	text_label.text = message

var dragging: bool = false
var drag_position: Vector2

func _on_gui_input(input: InputEvent) -> void:
	if (input is InputEventMouseButton and
		input.button_index == BUTTON_LEFT):
		if (input.pressed):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			drag_position = panel_container.get_global_mouse_position()
			dragging = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			panel_container.warp_mouse(drag_position)
			dragging = false
		return
		
	if (dragging and input is InputEventMouseMotion):
		var screen_size: Vector2 = OS.get_screen_size()
		var window_size: Vector2 = OS.get_window_size()
		var current_position = OS.get_window_position() + input.relative
		current_position.x = clamp(current_position.x, 0, screen_size.x - window_size.x)
		current_position.y = clamp(current_position.y, 0, screen_size.y - window_size.y)
		OS.set_window_position(current_position)
		
func _on_close_pressed() -> void:
	get_tree().quit()
