extends Node

class_name CompositeBattleOption

@export var display_name: String

func get_prompt():
	assert(false, "should be implemented in child class")

func get_options():
	assert(false, "should be implemented in child class")

func highlight_option(_actor, _option):
	# should highlight current actor?
	pass
