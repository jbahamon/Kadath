extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity

func _init(entity: String):
	self.entity = entity

func execute(cutscene_manager):
	var proxy: PlayerProxy = cutscene_manager.get_proxy()
	var new_parent = cutscene_manager.get_entity(self.entity) 
	proxy.set_target(new_parent)

func str():
	return "assign_proxy %s" % self.entity
