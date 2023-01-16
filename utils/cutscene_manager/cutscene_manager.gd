extends Node

var CutsceneParser = preload("res://utils/cutscene_manager/cutscene_parser.gd")	

signal overlay_fade_finished
signal move_camera_finished

export var camera_path: NodePath
export var local_scene_path: NodePath

onready var fade_overlay_tween: Tween = $OverlayFadeTween
onready var move_camera_tween: Tween = $CameraMoveTween

var local_scene: LocalScene setget , get_local_scene 
var camera: Camera2D

func _ready():
	self.camera = get_node(self.camera_path)
	
func get_local_scene():
	return get_node(self.local_scene_path)
	
func play_cutscene_from_file(cutscene_name: String):
	var parser = CutsceneParser.new()
	var cutscene_instruction = parser.parse_cutscene_from_file(cutscene_name)
	yield(self.play_cutscene(cutscene_instruction), "completed")
	
func play_cutscene_from_array(instructions: Array):
	var parser = CutsceneParser.new()
	var cutscene_instruction = parser.parse_cutscene_from_array(instructions)
	yield(self.play_cutscene(cutscene_instruction), "completed")
	
func play_cutscene(cutscene_instruction):
	var were_inputs_disabled = not self.get_local_scene().is_processing_unhandled_input()
	
	if not were_inputs_disabled:
		self.get_local_scene().disable_inputs()
		
	cutscene_instruction.run(self)
	
	if !cutscene_instruction.finished:
		yield(cutscene_instruction, "execution_finished")
		
	if not were_inputs_disabled:
		self.get_local_scene().enable_inputs()

func get_proxy():
	return self.get_local_scene().player_proxy
	
func get_party():
	return self.get_local_scene().party

func get_entity(entity_name: String):
	match entity_name:
		"CAMERA":
			return self.get_local_scene().camera
		"PROXY":
			return self.get_proxy()
		"ROOM":
			return self.get_local_scene().current_room
		"WORLD":
			return self.get_local_scene().world
		"PARTY":
			return self.get_party()
		_:
			return self.get_local_scene().get_room_object(entity_name)
			
func get_overlay(overlay: String):
	return self.get_local_scene().get_overlay(overlay)
	
func on_tween_completed(object, key):
	if object.has_method("on_tween_completed"):
		object.on_tween_completed()
	elif object == self.camera and key == ":global_position":
		emit_signal("move_camera_finished")
		
