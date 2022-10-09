extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity_name: String
var target

func _init(entity_name: String, target):
	self.entity_name = entity_name
	self.target = target
	
func execute(cutscene_manager):
	var target_position
	if self.target is Vector2:
		target_position = self.target
	else:
		var target_entity: Node2D = cutscene_manager.get_entity(self.target_entity)
		target_position = target_entity.position
	
	var entity: Node2D = cutscene_manager.get_entity(self.entity_name)
	entity.set_orientation((target_position - entity.position).normalized())
	
func str():
	return "look %s at %s" % [self.entity_name, self.target]
