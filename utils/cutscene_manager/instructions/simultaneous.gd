extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var instructions: Array

func _init():
	self.instructions = []
	
func execute(cutscene_manager):
	for instruction in instructions:
		instruction.run(cutscene_manager)
		
	for instruction in instructions:
		if !instruction.finished:
			yield(instruction, "execution_finished")
		
		
	
func add_instruction(instruction):
	self.instructions.append(instruction)
	
func str():
	return "start_simultaneous"
