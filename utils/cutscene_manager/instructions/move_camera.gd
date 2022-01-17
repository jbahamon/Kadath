extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var position: Vector2
var time: float
func _init(position, time):
	self.position = position
	self.time = time

func execute(cutscene_manager):
	cutscene_manager.tween.interpolate_property(
		cutscene_manager.camera, 
		"position", 
		cutscene_manager.camera.position, 
		self.position, 
		self.time
	)
	yield(cutscene_manager, "camera_move_finished")
	
func str():
	return "move_camera to %s in %f" % [str(self.position), self.time]
