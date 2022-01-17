extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var entity: String
var function_name: String
var args: Array

func _init(entity: String, function_name: String, args: Array):
	self.entity = entity
	self.function_name = function_name
	self.args = args
	
func execute(cutscene_manager):
	var entity: Node = cutscene_manager.get_entity(self.entity)
	var result = entity.callv(self.function_name, self.args)
	if result is GDScriptFunctionState:
		yield(result, "completed")

func str():
	return "call %s.%s(%s)" % [self.entity, self.function_name, self.args]
