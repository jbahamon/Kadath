extends Resource

class_name Location

@export var location_id: String 
@export var story: DialogueResource
@export var base_room_path: String

var room_classes: Dictionary = {}

func load_rooms() -> void:
	if room_classes.size() > 0:
		return
	var dir = DirAccess.open(base_room_path)
	dir.list_dir_begin()  # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547# TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	while true:
		var file = dir.get_next()
		
		if file == "":
			break
		elif not file.begins_with(".") and file.contains(".tscn"):
			file = file.replace(".remap", "")
			var room_path = "{path}/{file}".format({
				"path": base_room_path,
				"file": file
			})
			
			room_classes[file.replace(".tscn", "")] = load(room_path)
	dir.list_dir_end()
	
func instantiate_room(room_id: String) -> LocationRoom:
	var room_class = room_classes[room_id]
	return room_class.instantiate()
	
func free_rooms() -> void:
	room_classes = {}
