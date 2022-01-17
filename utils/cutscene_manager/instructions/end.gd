extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

func execute(cutscene_manager):
	var last_value = cutscene_manager.end_execution()
	if last_value is GDScriptFunctionState and last_value.is_valid():
		yield(last_value, "completed")

func str():
	return "end"
