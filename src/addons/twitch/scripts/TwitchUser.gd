class_name TwitchUser
extends Object

var name: String
var tags: Dictionary

func get_display_name() -> String:
	return tags["display-name"] if tags.has("display-name") else name

func add_tags(items: Dictionary) -> void:
	for tag_id in items: tags[tag_id] = items[tag_id]
