extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity

func _init(entity):
	self.entity = entity

func execute(cutscene_manager):
	var new_parent
	if self.entity is String:
		 new_parent = cutscene_manager.get_entity(self.entity) 
	else:
		new_parent = entity
	var proxy: PlayerProxy = cutscene_manager.get_proxy()
	
	proxy.set_target(new_parent)

func str():
	return "assign_proxy %s" % self.entity
