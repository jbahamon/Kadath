extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var instructions: Array

func _init():
	self.instructions = []
	
func execute(tree: SceneTree):
	for instruction in instructions:
		await instruction.run(tree)
		
func add_instruction(instruction):
	self.instructions.append(instruction)

func _to_string():
	return "start_sequential"
