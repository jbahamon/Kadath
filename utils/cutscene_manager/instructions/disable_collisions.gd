extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity_name: String

func _init(init_entity_name: String):
	self.entity_name = init_entity_name
	
func execute(tree: SceneTree):
	var entity: Node = EntitiesService.get_entity(self.entity_name)
	if entity.has_method("disable_collisions"):
		entity.disable_collisions()
	elif entity.has_method("set_disabled"):
		entity.set_disabled(true)

func _to_string():
	return "disable_collisions %s" % self.entity_name
