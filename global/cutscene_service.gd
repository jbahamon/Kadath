extends Node

var CutsceneParser = preload("res://utils/cutscene_manager/cutscene_parser.gd")	

var parser

func _init():
	self.parser = CutsceneParser.new()
	
func play_cutscene_from_file(cutscene_file_name: String):
	var cutscene_instruction = parser.parse_cutscene_from_file(cutscene_file_name)
	await self.play_cutscene(cutscene_instruction)
	
func play_custom_cutscene(instructions: Array):
	var cutscene_instruction = parser.parse_cutscene_from_array(instructions)
	await self.play_cutscene(cutscene_instruction)
	
func play_cutscene(cutscene_instruction):
	var was_input_enabled = InputService.is_input_enabled()
	var proxy = EntitiesService.get_proxy()
	var prev_proxy_mode = proxy.current_mode
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.set_input_enabled(false)
	await cutscene_instruction.execute(get_tree())
	InputService.set_input_enabled(was_input_enabled)
	proxy.set_mode(prev_proxy_mode)
