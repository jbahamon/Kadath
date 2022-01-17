extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

func execute(cutscene_manager):
	cutscene_manager.begin_simultaneous()

func str():
	return "start_simultaneous"
