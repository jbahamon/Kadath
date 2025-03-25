extends Node

var CutsceneParser = preload("res://utils/cutscene_manager/cutscene_parser.gd")
var parser
var pause_dialog: Window
var current_cutscene = null
var pausable = true
var popup: Popup

func _init():
	self.parser = CutsceneParser.new()
	

func _ready():
	self.set_process_unhandled_input(false)

func initialize(init_cutscene_popup):
	self.popup = init_cutscene_popup
		
func _unhandled_input(event):
	assert(self.current_cutscene != null)
	if event.is_action_pressed("ui_menu"):
		self.pause_cutscene()
		self.get_viewport().set_input_as_handled()

func play_cutscene_from_file(cutscene_file_name: String, options: Dictionary = {}):
	var cutscene_instruction = parser.parse_cutscene_from_file(cutscene_file_name)
	await self.play_cutscene(cutscene_instruction, options)
	
func play_custom_cutscene(instructions: Array, options: Dictionary = {}):
	var cutscene_instruction = parser.parse_cutscene_from_array(instructions)
	await self.play_cutscene(cutscene_instruction, options)
	
func play_cutscene(cutscene_instruction, options):
	assert(self.current_cutscene == null)
	self.current_cutscene = cutscene_instruction
	self.pausable = options.get("pausable", true)
	
	var was_input_enabled = InputService.input_enabled
	InputService.input_enabled = false
	
	var proxy = EntitiesService.proxy
	var prev_proxy_mode = proxy.current_mode
	if prev_proxy_mode == PlayerProxy.ProxyMode.GAMEPLAY:
		proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	
	var party: Party = EntitiesService.party
	var was_party_physics_enabled = party.is_physics_processing()
	party.set_physics_process(false)
	if self.pausable:
		self.set_process_unhandled_input(true)
	await self.current_cutscene.execute(get_tree(), CutsceneInstruction.ExecutionMode.PLAY)
	self.set_process_unhandled_input(false)
	var bg: ColorRect = FXService.get_layer("CUTSCENE_PAUSE")
	
	bg.visible = false
		
	var end_enable_input = options.get("end_enable_input")
	var end_proxy_mode = options.get("end_proxy_mode")
	
	InputService.input_enabled = was_input_enabled if end_enable_input == null else end_enable_input
	proxy.set_mode(prev_proxy_mode if end_proxy_mode == null else end_proxy_mode)
	party.set_physics_process(was_party_physics_enabled)
	if was_party_physics_enabled:
		party.reset_movement()
	self.current_cutscene = null

func pause_cutscene():
	assert(self.current_cutscene != null)
	self.current_cutscene.pause(get_tree())
	
	var bg: ColorRect = FXService.get_layer("CUTSCENE_PAUSE")
	bg.visible = true
	UIService.handle_popup(self.popup, true)
	
	if await self.popup.skip_chosen:
		skip_cutscene()
	else:
		resume_cutscene()
	bg.visible = false
	self.get_tree().paused = false
	
func resume_cutscene():
	assert(self.current_cutscene != null)
	self.current_cutscene.resume(get_tree())
	
func skip_cutscene():
	assert(self.current_cutscene != null)
	self.current_cutscene.skip(get_tree())
