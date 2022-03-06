extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity_name: String
var position: Vector2
var time: float
func _init(target, time):
	if target is Vector2:
		self.position = target
	elif target is String:
		self.entity_name = target
		
	self.time = time

func execute(cutscene_manager):
	if self.entity_name != null:
		var entity = cutscene_manager.get_entity(self.entity_name)
		self.position = entity.global_position
	
	cutscene_manager.move_camera_tween.interpolate_property(
		cutscene_manager.camera, 
		"global_position", 
		cutscene_manager.camera.global_position, 
		self.position,
		self.time
	)
	cutscene_manager.move_camera_tween.start()
	
	yield(cutscene_manager, "move_camera_finished")
	
func str():
	return "move_camera to %s in %f" % [str(self.position), self.time]
