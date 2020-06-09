extends Node

onready var panel_container	: PanelContainer = $PanelContainer
onready var panel			: Panel = $PanelContainer/Panel
onready var close_button	: TextureButton = $PanelContainer/Panel/CloseButton
onready var name_label		: Label = $PanelContainer/Panel/NameLabel
onready var text_label		: Label = $PanelContainer/Panel/TextLabel
onready var text_timer		: Timer = $TextTimer
onready var sound_player	: AudioStreamPlayer = $SoundPlayer
onready var twitch			: TwitchChat = $TwitchChat

var sounds: Dictionary = {
	"beep" : load("res://sounds/tone.wav"),
	"honk" : load("res://sounds/honk.wav")
}

var dragging: bool = false
var drag_position: Vector2

func _ready():
	panel.connect("gui_input", self, "_on_gui_input")
	close_button.connect("pressed", self, "_on_close_pressed")
	text_timer.connect("timeout", self, "_on_text_timer")
	twitch.connect("user_message", self, "_on_user_message")
	twitch.start_with("res://twitch.cfg")
	text_timer.start()

func _on_user_message(user: TwitchUser, message: String) -> void:
	var play_id:String = "beep"
	if (message[0] == "!"):
		var position: int = message.find(" ")
		if (position < 0): position = message.length()
		var command: String = message.substr(1, position - 1).to_lower()
		message = message.substr(position + 1).strip_edges( true, false)
		var method: String = "_on_command_" + command
		if (not has_method(method)):play_id = command
		else: message = call(method, user, message)
	if (message.length() != 0):
		if (sounds.has(play_id)):
			sound_player.stream = sounds[play_id]
			sound_player.play()
			text_timer.stop()
		name_label.self_modulate = user.get_color()
		name_label.text = user.get_display_name()
		text_label.text = message
		text_label.lines_skipped = 0
		if (text_label.get_line_count() >
			text_label.get_visible_line_count()):
			text_timer.start()

func _on_command_reset(user: TwitchUser, message: String) -> String:
	name_label.text = ""
	text_label.text = ""
	text_timer.stop()
	return ""

func _on_text_timer() -> void:
	var lines: int = text_label.lines_skipped + 1
	if (lines == text_label.get_line_count()): lines = 0
	text_label.lines_skipped = lines

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
