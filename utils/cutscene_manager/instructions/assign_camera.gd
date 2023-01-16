extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity

func _init(entity: String):
	self.entity = entity

func execute(cutscene_manager):
	var camera: Camera2D = cutscene_manager.camera
	var camera_parent = camera.get_parent()
	var old_parent_position = Vector2.ZERO
	
	if camera_parent != null:
		old_parent_position = camera_parent.position
		camera_parent.remove_child(camera)
	
	var old_position = camera.position
	
	var new_parent = cutscene_manager.get_entity(self.entity) 
	new_parent.add_child(camera)
	
	if self.entity == "WORLD":
		camera.position = old_parent_position + old_position
	else:
		camera.position = old_parent_position + old_position - new_parent.position

func str():
	return "assign_camera %s" % self.entity
