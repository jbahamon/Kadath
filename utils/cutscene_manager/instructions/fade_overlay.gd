extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

signal finished

var overlay: String
var color: Color
var time: float
var overlay_object
var _cutscene_manager

func _init(overlay: String, color: Color, time: float):
	self.overlay = overlay
	self.color = color
	self.time = time
	self.overlay_object = null

func execute(cutscene_manager):
	self._cutscene_manager = cutscene_manager
	self.overlay_object = cutscene_manager.get_overlay(overlay)
	
	var original_color = self.overlay_object.color
	self._cutscene_manager.fade_overlay_tween.interpolate_method(
		self,
		"interpolate",
		original_color,
		self.color,
		self.time
	)
	self._cutscene_manager.fade_overlay_tween.start()
	
	yield(self, "finished")
	
func interpolate(value: Color):
	if self.overlay_object == null:
		return

	var actual_color = Color(
		stepify(value.r, 0.05), 
		stepify(value.g, 0.05),
		stepify(value.b, 0.05), 
		stepify(value.a, 0.05)
	)
	self.overlay_object.color = actual_color

func on_tween_completed():
	emit_signal("finished")

func str():
	return "fade_overlay %s to %s in %f" % [
		self.overlay, str(self.color), self.time
	]
