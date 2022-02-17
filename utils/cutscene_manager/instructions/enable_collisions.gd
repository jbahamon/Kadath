extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity: String

func _init(entity: String):
	self.entity = entity
	
func execute(cutscene_manager):
	var entity: Node = cutscene_manager.get_entity(self.entity)
	if entity.has_method("enable_collisions"):
		entity.enable_collisions()
	elif entity.has_method("set_disabled"):
		entity.set_disabled(false)
	
func str():
	return "enable_collisions %s" % self.entity
