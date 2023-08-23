extends Resource

class_name Location

@export var location_id: String 
@export var story: DialogueResource
@export var base_room_path: String

var room_scenes: Dictionary = {}

func load_rooms() -> void:
	if room_scenes.size() > 0:
		return
	var dir = DirAccess.open(base_room_path)
	dir.list_dir_begin()  # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547# TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".tscn"):
			var room_path = "{path}/{file}".format({
				"path": base_room_path,
				"file": file
			})
			var room_class = load(room_path)
			var room = room_class.instantiate()
			room_scenes[file.replace(".tscn", "")] = room
	dir.list_dir_end()
	
func get_room(room_id: String) -> LocationRoom:
	return room_scenes.get(room_id)
	
func free_rooms() -> void:
	for room in room_scenes.values():
		room.queue_free()
	room_scenes = {}
