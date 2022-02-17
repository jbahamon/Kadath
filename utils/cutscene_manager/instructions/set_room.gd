extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var room_name

func _init(room_name: String):
	self.room_name = room_name
	
func execute(cutscene_manager):
	var local_scene: LocalScene = cutscene_manager.local_scene
	local_scene.move_to_room(self.room_name, Vector2(0,0), Vector2.DOWN)

func str():
	return "set_room to %s" % self.room_name
