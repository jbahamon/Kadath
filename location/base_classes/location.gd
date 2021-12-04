extends Resource

class_name Location

export var location_id: String 
export var story: Resource
export(Array, String) var room_paths: Array

var room_scenes: Dictionary = {}

func load_rooms() -> void:
	if room_scenes.size() > 0:
		return
		
	for path in room_paths:
		var room: LocationRoom = load(path).instance()
		room_scenes[room.room_id] = room
		
func get_room(room_id: String) -> Room:
	return room_scenes.get(room_id)
	
func free_rooms() -> void:
	for room in room_scenes.values():
		room.queue_free()
	room_scenes = {}
