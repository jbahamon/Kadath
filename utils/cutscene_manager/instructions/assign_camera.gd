extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity_name

func _init(init_entity_name: String):
	self.entity_name = init_entity_name

func execute(_tree: SceneTree):
	CameraService.assign_camera(EntitiesService.get_entity(self.entity_name))

func _to_string():
	return "assign_camera %s" % self.entity_name
