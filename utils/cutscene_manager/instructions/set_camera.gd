extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var position: Vector2
func _init(position: Vector2):
	self.position = position
	

func execute(cutscene_manager):
	cutscene_manager.camera.position = self.position
	
func str():
	return "set_camera to %s" % str(self.position)
