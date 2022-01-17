extends Node

var CutsceneParser = preload("res://utils/cutscene_manager/cutscene_parser.gd")	

signal overlay_fade_finished
signal move_camera_finished

export var overlay_path: NodePath
export var camera_path: NodePath
export var local_scene_path: NodePath

onready var tween: Tween = $Tween

var local_scene: LocalScene
var overlay: CanvasItem
var camera: Camera2D


class ExecutionMode:
	func on_executed_instruction(state: GDScriptFunctionState):
		pass
	func finish() -> GDScriptFunctionState:
		return null
		
class SimultaneousExecution extends ExecutionMode:
	var function_states = []
			
	func on_executed_instruction(state: GDScriptFunctionState):
		function_states.append(state)
		
	func finish():
		yield(self.wait_for_all(), "completed")
		return null
		
	func wait_for_all() -> bool:
		for state in self.function_states:
			if state.is_valid():
				yield(state, "completed")
		return true
		
class SequentialExecution extends ExecutionMode:
	func on_executed_instruction(state: GDScriptFunctionState):
		yield(state, "completed")

var execution_stack: Array

func _ready():
	self.overlay = get_node(self.overlay_path)
	self.camera = get_node(self.camera_path)
	self.local_scene = get_node(self.local_scene_path)
	
func play_cutscene(cutsceneName: String):
	var parser = CutsceneParser.new()
	var instructions = parser.parse_cutscene(cutsceneName)
	self.local_scene.start_cutscene()
	var execution_result = self.run_cutscene_instructions(instructions);
	
	if execution_result is GDScriptFunctionState and execution_result.is_valid(true):
		yield(execution_result, "completed")
		
	self.local_scene.end_cutscene()
	
func run_cutscene_instructions(instructions: Array):
	self.execution_stack = []
	self.execution_stack.push_back(SequentialExecution.new())
	
	for instruction in instructions:
		print(instruction.str())
		var execution_value: GDScriptFunctionState = instruction.execute(self)
		
		if execution_value != null:
			var instruction_processing = self.get_execution_mode().on_executed_instruction(execution_value)
			if instruction_processing != null:
				yield(instruction_processing, "completed")
				

	while not execution_stack.empty():
		var last_value = self.execution_stack.pop_back().finish()
		if last_value is GDScriptFunctionState and last_value.is_valid(true):
			yield(last_value, "completed")
	
func begin_sequential():
	self.execution_stack.push_back(SequentialExecution.new())
	
func begin_simultaneous():
	self.execution_stack.push_back(SimultaneousExecution.new())
	
func end_execution():
	yield(self.execution_stack.pop_back().finish(), "completed")
	
func get_execution_mode() -> ExecutionMode:
	return self.execution_stack.back()

func get_entity(entity_name: String):
	return local_scene.get_room_object(entity_name)
	
func on_tween_completed(object, key):
	if object == self.overlay and key == ":modulate":
		print("finished")
		emit_signal("overlay_fade_finished")
	elif object == self.camera and key == "position":
		emit_signal("move_camera_finished")
		
		
