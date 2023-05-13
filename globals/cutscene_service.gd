extends Node

var CutsceneParser = preload("res://utils/cutscene_manager/cutscene_parser.gd")	

var parser

func _init():
	self.parser = CutsceneParser.new()
	
func play_cutscene_from_file(cutscene_name: String):
	var cutscene_instruction = parser.parse_cutscene_from_file(cutscene_name)
	await self.play_cutscene(cutscene_instruction)
	
func play_custom_cutscene(instructions: Array):
	var cutscene_instruction = parser.parse_cutscene_from_array(instructions)
	await self.play_cutscene(cutscene_instruction)
	
func play_cutscene(cutscene_instruction):
	var were_inputs_disabled = InputService.disable_inputs()
		
	await cutscene_instruction.execute(get_tree())
	
	if not were_inputs_disabled:
		InputService.enable_inputs()
