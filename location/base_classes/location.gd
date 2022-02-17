extends Resource

class_name Location

export var location_id: String 
export var story: Resource
export var base_room_path: String

var room_scenes: Dictionary = {}

func load_rooms() -> void:
	if room_scenes.size() > 0:
		return
	var dir = Directory.new()
	dir.open(base_room_path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".tscn"):
			var room_path = "{path}/{file}".format({
				"path": base_room_path,
				"file": file
			})
			var room: LocationRoom = load(room_path).instance()
			room_scenes[file.replace(".tscn", "")] = room
		
func get_room(room_id: String) -> Room:
	return room_scenes.get(room_id)
	
func free_rooms() -> void:
	for room in room_scenes.values():
		room.queue_free()
	room_scenes = {}
