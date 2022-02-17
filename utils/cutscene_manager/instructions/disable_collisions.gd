extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity: String

func _init(entity: String):
	self.entity = entity
	
func execute(cutscene_manager):
	var entity: Node = cutscene_manager.get_entity(self.entity)
	if entity.has_method("disable_collisions"):
		entity.disable_collisions()
	elif entity.has_method("set_disabled"):
		entity.set_disabled(true)

func str():
	return "disable_collisions %s" % self.entity
