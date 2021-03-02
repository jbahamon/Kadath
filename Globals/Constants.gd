extends Node

var items


func _init():
	var items_file = File.new()
	items_file.open("res://Items/items.json", File.READ)
	var content = items_file.get_as_text()
	items_file.close()
	items = parse_json(content)
