extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"


var overlay: String
var color: Color
var time: float
var overlay_object

func _init(init_overlay: String, init_color: Color, init_time: float):
	self.overlay = init_overlay
	self.color = init_color
	self.time = init_time
	self.overlay_object = null

func execute(tree: SceneTree):
	self.overlay_object = LayersService.get_layer(overlay)
	
	var original_color = self.overlay_object.color
	var tween = tree.create_tween()
	
	tween.tween_method(
		self.sample,
		original_color,
		self.color,
		self.time
	)
	await tween.finished
	
func sample(value: Color):
	if self.overlay_object == null:
		return

	var actual_color = Color(
		snapped(value.r, 0.05), 
		snapped(value.g, 0.05),
		snapped(value.b, 0.05), 
		snapped(value.a, 0.05)
	)
	self.overlay_object.color = actual_color

func _to_string():
	return "fade_overlay %s to %s in %f" % [
		self.overlay, str(self.color), self.time
	]
