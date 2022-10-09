extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var character: String
var position: Vector2
var speed: float

func _init(character: String, position: Vector2, speed: float):
	self.character = character
	self.position = position
	self.speed = speed
	
func execute(cutscene_manager):
	var entity = cutscene_manager.get_entity(character)
	yield(entity.move_to(position, speed), "completed")

func str():
	return "move %s to %s at %f" % [self.character, str(self.position), self.speed]
