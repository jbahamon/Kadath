extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var movement_param
var mode: String
var position: Vector2
var time: float

func _init(movement_param, mode, time):
	self.movement_param = movement_param
	self.mode = mode	
	self.time = time

func execute(cutscene_manager):
	match self.mode:
		"target_entity":
			var entity = cutscene_manager.get_entity(self.movement_param)
			self.position = entity.global_position	
		"target_position":
			self.position = movement_param
		"displacement":
			self.position = cutscene_manager.camera.global_position + self.movement
		
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
