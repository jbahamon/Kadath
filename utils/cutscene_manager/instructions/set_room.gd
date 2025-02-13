extends CutsceneInstruction

var room_name

func _init(starting_room_name: String):
	self.room_name = starting_room_name
	
func execute(_tree: SceneTree, _mode: ExecutionMode):
	var current_location_id = EnvironmentService.current_location.location_id
	await EnvironmentService.update_whereabouts(
		current_location_id, 
		self.room_name,
		Vector2(0,0), 
		Vector2.DOWN,
		{
			"fade": false
		}
	) 
	
func _to_string():
	return "set_room to %s" % self.room_name
