extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var position: Vector2

func _init(init_position: Vector2):
	self.position = init_position

func execute(_tree: SceneTree):
	CameraService.set_camera_position(self.position)
	
func _to_string():
	return "set_camera to %s" % str(self.position)
