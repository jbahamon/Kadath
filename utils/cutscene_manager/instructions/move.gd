extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity_name: String
var position: Vector2
var speed: float

func _init(init_entity_name: String, init_position: Vector2, init_speed: float):
	self.entity_name = init_entity_name
	self.position = init_position
	self.speed = init_speed
	
func execute(_tree: SceneTree):
	var entity = EntitiesService.get_entity(self.entity_name)
	if speed != INF:
		await entity.move_to(position, speed)
	else:
		entity.position = position

func _to_string():
	return "move %s to %s at %f" % [self.entity_name, str(self.position), self.speed]
