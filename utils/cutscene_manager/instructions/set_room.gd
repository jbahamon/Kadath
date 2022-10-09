extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var room_name

func _init(room_name: String):
	self.room_name = room_name
	
func execute(cutscene_manager):
	var local_scene: LocalScene = cutscene_manager.local_scene
	var current_location_id = local_scene.current_location.location_id
	local_scene.update_whereabouts(
		current_location_id, 
		self.room_name,
		Vector2(0,0), 
		Vector2.DOWN,
		false
	) 
	
func str():
	return "set_room to %s" % self.room_name
