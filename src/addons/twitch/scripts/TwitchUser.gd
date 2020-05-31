class_name TwitchUser
extends Object

var name: String
var tags: Dictionary

func get_display_name() -> String:
	return tags["display-name"] if tags.has("display-name") else name

func get_color() -> Color:
	var color: Color = Color.white
	if (tags.has("color")):
		var color_code: String = tags["color"]
		if (color_code): color = Color(color_code)
	return color

func set_tags(items: Dictionary) -> void:
	for tag_id in items: tags[tag_id] = items[tag_id]
