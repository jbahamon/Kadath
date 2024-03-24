extends Node

var CutsceneParser = preload("res://utils/cutscene_manager/cutscene_parser.gd")	

var parser

func _init():
	self.parser = CutsceneParser.new()
	
func play_cutscene_from_file(cutscene_file_name: String, enable_input_on_finish=null, proxy_mode_on_finish=null):
	var cutscene_instruction = parser.parse_cutscene_from_file(cutscene_file_name)
	await self.play_cutscene(cutscene_instruction, enable_input_on_finish, proxy_mode_on_finish)
	
func play_custom_cutscene(instructions: Array, enable_input_on_finish=null, proxy_mode_on_finish=null):
	var cutscene_instruction = parser.parse_cutscene_from_array(instructions)
	await self.play_cutscene(cutscene_instruction, enable_input_on_finish, proxy_mode_on_finish)
	
func play_cutscene(cutscene_instruction, enable_input_on_finish, proxy_mode_on_finish):
	var was_input_enabled = InputService.is_input_enabled()
	InputService.set_input_enabled(false)
	
	var proxy = EntitiesService.get_proxy()
	var prev_proxy_mode = proxy.current_mode
	if prev_proxy_mode == PlayerProxy.ProxyMode.GAMEPLAY:
		proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	
	# It might be useful to have this as an argument like the others, but for now this works
	var party: Party = EntitiesService.get_party()
	var was_party_physics_enabled = party.is_physics_processing()
	party.set_physics_process(false)
	
	await cutscene_instruction.execute(get_tree())
	
	InputService.set_input_enabled(was_input_enabled if enable_input_on_finish == null else enable_input_on_finish)
	proxy.set_mode(prev_proxy_mode if proxy_mode_on_finish == null else proxy_mode_on_finish)
	party.set_physics_process(was_party_physics_enabled)
	if was_party_physics_enabled:
		party.reset_movement()
