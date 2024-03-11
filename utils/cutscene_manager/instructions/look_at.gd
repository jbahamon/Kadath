extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity_name: String
var target

func _init(init_entity_name: String, init_target):
	self.entity_name = init_entity_name
	self.target = init_target
	
func execute(_tree: SceneTree):
	var target_position
	if self.target is Vector2:
		target_position = self.target
	else:
		var target_entity: Node2D = EntitiesService.get_entity(self.target)
		target_position = target_entity.position
	
	var entity: Node2D = EntitiesService.get_entity(self.entity_name)
	entity.set_orientation((target_position - entity.position).normalized())
	
func _to_string():
	return "look %s at %s" % [self.entity_name, self.target]
