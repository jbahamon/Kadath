extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var overlay: String
var color: Color

func _init(overlay: String, color: Color):
	self.overlay = overlay
	self.color = color

func execute(cutscene_manager):
	cutscene_manager.get_overlay(self.overlay).color = self.color

func str():
	return "set_overlay to %s" % str(self.color)
