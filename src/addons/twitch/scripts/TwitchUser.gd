"""
*************************************************************************
*  TwitchUser.gd                                                        *
*************************************************************************
*                       This file is part of:                           *
*                    TwitchChat Godot Plugin 1.3                        *
*                https://github/1bitgodot/TwitchChat                    *
*************************************************************************
* Copyright (c) 2020 Phillip Madden                                     *
*                                                                       *
* Permission is hereby granted, free of charge, to any person obtaining *
* a copy of this software and associated documentation files (the       *
* "Software"), to deal in the Software without restriction, including   *
* without limitation the rights to use, copy, modify, merge, publish,   *
* distribute, sublicense, and/or sell copies of the Software, and to    *
* permit persons to whom the Software is furnished to do so, subject to *
* the following conditions:                                             *
*                                                                       *
* The above copyright notice and this permission notice shall be        *
* included in all copies or substantial portions of the Software.       *
*                                                                       *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       *
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    *
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  *
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  *
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     *
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                *
*************************************************************************
"""

class_name TwitchUser
extends Reference

var name: String
var tags: Dictionary

func get_display_name() -> String:
	return tags["display-name"] if tags.has("display-name") else name

func get_color() -> Color:
	return Color(tags["color"]) if tags.has("color") else Color.white

func set_tags(items: Dictionary) -> void:
	for tag_id in items: tags[tag_id] = items[tag_id]
