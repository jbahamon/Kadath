extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity_name_or_entity

func _init(init_entity_name_or_entity):
	self.entity_name_or_entity = init_entity_name_or_entity

func execute(tree: SceneTree):
	var new_parent
	if self.entity is String:
		new_parent = EntitiesService.get_entity(self.entity_name_or_entity) 
	else:
		new_parent = self.entity_name_or_entity
	var proxy: PlayerProxy = EntitiesService.get_proxy()
	
	proxy.set_target(new_parent)

func _to_string():
	return "assign_proxy %s" % self.entity_name_or_entity
