extends Node

var CutsceneParser = preload("res://utils/cutscene_manager/CutsceneParser.cs")	

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
		
	func finish() -> GDScriptFunctionState:
		return yield(self.wait_for_all(), "completed")
		
	func wait_for_all() -> bool:
		for state in self.function_states:
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
	var instructions = parser.ParseCutscene(cutsceneName)
	self.run_cutscene_instructions(instructions)
	
func run_cutscene_instructions(instructions: Array):
	self.execution_stack = []
	self.execution_stack.push_back(SequentialExecution.new())
	
	for instruction in instructions:
		
		var cutscene_instruction = instruction as CutsceneInstruction
		var function_return: GDScriptFunctionState = self.execute_instruction(cutscene_instruction)
		
		if function_return != null:
			self.get_execution_mode().on_executed_instruction(function_return)

func execute_instruction(cutscene_instruction: CutsceneInstruction):
	match cutscene_instruction.type:
		
		CutsceneInstruction.Type.SET_OVERLAY: 
			self.overlay.modulate = cutscene_instruction.args["Color"]
			
		CutsceneInstruction.Type.FADE_OVERLAY:
			yield(self.fade_overlay(
				cutscene_instruction.args["Color"],
				cutscene_instruction.args["Time"]
			), "completed")
			
		CutsceneInstruction.Type.SET_CAMERA: 
			self.camera.position = cutscene_instruction.args["Color"]
			
		CutsceneInstruction.Type.MOVE_CAMERA: 
			yield(self.move_camera(
				cutscene_instruction.args["Position"],
				cutscene_instruction.args["Time"]
			), "completed")
			
		CutsceneInstruction.Type.NPC_WALK: pass
		
		CutsceneInstruction.Type.OPEN_DIALOG: 
			yield(
				local_scene.open_dialog(cutscene_instruction.args["Dialog"]), 
				"completed"
			)
			
		CutsceneInstruction.Type.SIMULTANEOUS: 
			self.execution_stack.push_back(SimultaneousExecution.new())
			
		CutsceneInstruction.Type.SEQUENTIAL:
			self.execution_stack.push_back(SequentialExecution.new())
			
		CutsceneInstruction.Type.END: 
			yield(self.execution_stack.pop_back().finish(), "completed")
			
	return null

func get_execution_mode() -> ExecutionMode:
	return self.execution_stack.back()


func fade_overlay(color: Color, time: float):
	tween.interpolate_property(overlay, "modulate", overlay.modulate, color, time)
	yield(self, "overlay_fade_finished")

func move_camera(position: Vector2, time: float):
	tween.interpolate_property(camera, "position", camera.position, position, time)
	yield(self, "camera_move_finished")

func on_tween_completed(object, key):
	if object == self.overlay and key == "modulate":
		emit_signal("overlay_fade_finished")
	elif object == self.camera and key == "position":
		emit_signal("move_camera_finished")
		
		
