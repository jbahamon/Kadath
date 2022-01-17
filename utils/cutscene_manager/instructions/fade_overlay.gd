extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var color: Color
var time: float
var manager_signal = "overlay_fade_finished"
var _cutscene_manager
func _init(color: Color, time: float):
	self.color = color
	self.time = time

func execute(cutscene_manager):
	self._cutscene_manager = cutscene_manager
	var original_color = cutscene_manager.overlay.modulate
	cutscene_manager.tween.interpolate_method(
		self,
		"interpolate",
		original_color,
		self.color,
		self.time
	)
	cutscene_manager.tween.start()
	yield(cutscene_manager, self.manager_signal)
	
func interpolate(value: Color):
	var actual_color = Color(
		stepify(value.r, 0.05), 
		stepify(value.g, 0.05),
		stepify(value.b, 0.05), 
		stepify(value.a, 0.05)
	)
	self._cutscene_manager.overlay.modulate = actual_color
func str():
	return "fade_overlay to %s in %f" % [str(self.color), self.time]
