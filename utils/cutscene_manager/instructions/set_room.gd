extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var room_name

func _init(starting_room_name: String):
	self.room_name = starting_room_name
	
func execute(_tree: SceneTree):
	var current_location_id = EnvironmentService.get_location().location_id
	EnvironmentService.update_whereabouts(
		current_location_id, 
		self.room_name,
		Vector2(0,0), 
		Vector2.DOWN,
		false
	) 
	
func _to_string():
	return "set_room to %s" % self.room_name
