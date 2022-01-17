extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

func execute(cutscene_manager):
	yield(cutscene_manager.end_execution(), "completed")

func str():
	return "end"
