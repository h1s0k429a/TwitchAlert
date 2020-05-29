class_name TwitchChat, "res://addons/twitch/assets/twitch.png"
extends Node

signal server_response(response)
signal user_message(user, message)
signal user_join(user)
signal user_left(user)

const CONFIG_NAME: String 	= "twitch"
const SERVER_HOST: String 	= "irc.chat.twitch.tv"
const SERVER_PORT: int 		= 6667
const PACKET_SIZE: int 		= 256

export var nick_name	: String		# twitch account name for chat bot (in lowercase)
export var auth_token	: String		# twitch account user access token (obtain from https://twitchapps.com/tmi/)
export var channel_id	: String		# the channel for chat bot to join to send and receive user channel messages
export var send_speed	: float	= 1.5	# seconds per message (read https://dev.twitch.tv/docs/irc/guide#command--message-limits))
export var debug		: bool			# display commands and responses in Godot Output window

var server		: StreamPeerTCP
var users		: Dictionary
var out_queue	: Array
var connected	: bool
var send_wait	: bool

func start() -> void:
	if (not connected):
		server = StreamPeerTCP.new()
		var error = server.connect_to_host(SERVER_HOST, SERVER_PORT)
		if (error != OK): push_error("Failed to connect to %s:%d" % [SERVER_HOST, SERVER_PORT])
		else:
			connected = true
			error = connect("server_response", self, "_on_server_response")
			send_command("PASS " + auth_token	)
			send_command("NICK " + nick_name	)
			send_command("JOIN #" + channel_id	)
			send_command("CAP REQ :twitch.tv/membership twitch.tv/tags twitch.tv/commands")

func start_with(configuration_path: String) -> void:
	var configuration = ConfigFile.new()
	var error: int = configuration.load(configuration_path)
	if (error != OK): push_error("Error loading configuration file '%s'" % configuration_path)
	else:
		nick_name	= configuration.get_value(CONFIG_NAME, "nick_name"	, "1bitgodot"								)
		auth_token	= configuration.get_value(CONFIG_NAME, "auth_token"	, "oauth:z4sduqv56lmwhcjexykv7my0tpr2xu"	)
		channel_id	= configuration.get_value(CONFIG_NAME, "channel_id"	, "1bitgodot"								)
		send_speed  = configuration.get_value(CONFIG_NAME, "send_speed" , 1.5										)	
		# example configuration file format:
		#	[twitch]
		#	nick_name  = "1bitgodot_bot"
		#	auth_token = "oauth:z4sduqv56lmwhcjexykv7my0tpr2xu"
		#	channel_id = "1bitgodot"
		#	send_speed = 1.5
		start()

func close() -> void:
	if (connected):
		connected = false
		send_wait = false
		disconnect("server_response", self, "_on_server_response")
		server.disconnect_from_host()
		users = Dictionary()
		out_queue.clear()
		server.free()

func send_command(command: String) -> void:
	if (debug): print("command> ", command)
	out_queue.append(command + "\r\n")

func send_message(message: String) -> void:
	send_command("PRIVMSG #" + channel_id + " :" + message)

func _process(_delta: float) -> void:
	if (connected):
		var length: int = server.get_available_bytes()
		if (length > 0): emit_signal("server_response", server.get_utf8_string(length))
		if (not send_wait and out_queue.size() > 0):
			send_wait = true
			var command: String = out_queue[0]
			var packets: int = command.length() / PACKET_SIZE
			var remains: int = command.length() % PACKET_SIZE
			var timeout: SceneTreeTimer = get_tree().create_timer(send_speed)
			for packet in range(packets): var _error = server.put_data(command.substr(packet * PACKET_SIZE, PACKET_SIZE).to_utf8())
			if (remains > 0): var _error = server.put_data(command.substr(packets * PACKET_SIZE, remains).to_utf8())
			yield(timeout, "timeout")
			out_queue.remove(0)
			send_wait = false

func _handle_p_message_response(prefix: String, tags: Dictionary, message: String) -> void:
	if (not users.has(prefix)): _handle_join_response(prefix)
	var user: TwitchUser = users[prefix]
	if (tags.size() != 0): user.add_tags(tags)
	emit_signal("user_message", user, message)

func _handle_userstate_response(prefix: String, tags: Dictionary) -> void:
	if (not users.has(prefix)): _handle_join_response(prefix)
	if (tags.size() != 0): users[prefix].add_tags(tags)

func _handle_join_response(prefix: String) -> void:
	if (not users.has(prefix)):
		var user: TwitchUser = TwitchUser.new()
		user.name = prefix.substr(0, prefix.find("!"))
		emit_signal("user_join", user)
		users[prefix] = user

func _handle_part_response(prefix: String) -> void:
	if (users.has(prefix)):
		var user: TwitchUser = users[prefix]
		var _error = users.erase(prefix)
		emit_signal("user_left", user)
		user.free()

func _handle_ping_response(message: String) -> void:
	send_command("PONG :" + message)

func _parse_tags(text: String) -> Dictionary:
	var tags: Dictionary = Dictionary()
	while true:
		var position1: int = text.find("=")
		if (position1 > 0):
			var key: String = text.substr(0, position1)
			var position2	= text.find(";", position1 + 1)
			if (position2 < 0): position2 = text.length()
			tags[key] = text.substr(position1 + 1, position2 - (position1 + 1))
			text = text.substr(position2 + 1)
		else: break
	return tags

func _on_server_response(response: String) -> void:
	if (debug)	: print("response> ",response.strip_edges())
	var tags	: Dictionary
	var prefix	: String
	var message : String
	var command	: String
	var _params	: PoolStringArray
	if (response[0] == "@"):
		var position: int = response.find(" ")
		tags = _parse_tags(response.substr(1, position - 1))
		response = response.substr(position + 1)
	if (response[0] == ":"):
		var position: int = response.find(" ")
		prefix = response.substr(1, position - 1)
		response = response.substr( position + 1)
	var position: int = response.find(" :")	
	if (position > 0):
		message = response.substr(position + 2).strip_edges()
		response = response.substr(0, position)
	position = response.find(" ")
	if (position > 0):
		command = response.substr( 0, position)
		_params = response.substr(position + 1).split(" ")
	else: command = response
	match command:
		"PRIVMSG"	: _handle_p_message_response(prefix, tags, message)
		"USERSTATE"	: _handle_userstate_response(prefix, tags)
		"JOIN"		: _handle_join_response(prefix )
		"PART"		: _handle_part_response(prefix )
		"PING"		: _handle_ping_response(message)
