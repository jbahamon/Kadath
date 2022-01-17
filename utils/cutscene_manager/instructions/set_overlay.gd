extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var color: Color

func _init(color: Color):
	self.color = color

func execute(cutscene_manager):
	cutscene_manager.overlay.color = self.color

func str():
	return "set_overlay to %s" % str(self.color)
