extends Node


enum Positions {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

onready var panel: Panel = $PanelContainer/Panel
onready var panel_container: PanelContainer = $PanelContainer
onready var name_label: Label = $PanelContainer/Panel/NameLabel
onready var text_label: Label = $PanelContainer/Panel/TextLabel
onready var sound_player: AudioStreamPlayer = $SoundPlayer
onready var popup_menu: PopupMenu = $PopupMenu
onready var twitch: TwitchChat = $TwitchChat

var sounds: Dictionary = {
	"tone" : load("res://sounds/tone.wav"),
	"honk" : load("res://sounds/honk.wav")
}


func _ready():
	reposition(2)
	get_tree().get_root().set_transparent_background(true)
	panel.connect("gui_input", self, "_on_gui_input")
	popup_menu.connect("id_pressed", self, "_on_menu_item_pressed")
	twitch.connect("user_message", self, "_on_user_message")
	twitch.start_with("res://project.cfg")

func create_menu() -> void:
	popup_menu.add_separator("Alignment" )
	popup_menu.add_item("1. Top Left"		, 1)
	popup_menu.add_item("2. Top Right"		, 2)
	popup_menu.add_item("3. Bottom Left"	, 3)
	popup_menu.add_item("4. Bottom Right"	, 4)
	popup_menu.add_separator()
	popup_menu.add_item("Close"				, 5)
	
func reposition(index: int) -> void:
	var screen_size: Vector2 = OS.get_screen_size()
	var window_size: Vector2 = OS.get_window_size()
	match index:
		Positions.TOP_LEFT		:
			OS.set_window_position(Vector2(0, 0))
			panel_container.rect_position = Vector2(0,0)
		Positions.TOP_RIGHT		:
			OS.set_window_position(Vector2(screen_size.x - window_size.x, 0))
			panel_container.rect_position = Vector2(window_size.x - panel_container.rect_size.x, 0)
		Positions.BOTTOM_LEFT	:
			OS.set_window_position(Vector2(0, screen_size.y - window_size.y))
			panel_container.rect_position = Vector2(0, window_size.y - panel_container.rect_size.y)
		Positions.BOTTOM_RIGHT	:
			OS.set_window_position(Vector2(screen_size.x - window_size.x, screen_size.y - window_size.y))
			panel_container.rect_position = Vector2(window_size.x - panel_container.rect_size.x, window_size.y - panel_container.rect_size.y)

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
	name_label.text = user.get_display_name()
	text_label.text = message

func _on_gui_input(input: InputEvent) -> void:
	if (input is InputEventMouseButton and input.pressed and
		input.button_index == BUTTON_RIGHT):
		popup_menu.popup()
		pass
		
func _on_menu_item_pressed(id: int) -> void:
	match id:
		1: reposition(Positions.TOP_LEFT	)
		2: reposition(Positions.TOP_RIGHT	)
		3: reposition(Positions.BOTTOM_LEFT	)
		4: reposition(Positions.BOTTOM_RIGHT)
		5: get_tree().quit()

