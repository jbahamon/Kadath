extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity

func _init(entity: String):
	self.entity = entity

func execute(cutscene_manager):
	var camera: Camera2D = cutscene_manager.camera
	var camera_parent = camera.get_parent()
	
	if camera_parent != null:
		camera_parent.remove_child(camera)
	
	var new_parent = cutscene_manager.get_entity(self.entity) 
	new_parent.add_child(camera)
	if self.entity != "WORLD":
		camera.position = Vector2.ZERO

func str():
	return "assign_camera %s" % self.entity