extends CutsceneInstruction

var overlay: String
var color: Color
var time: float
var overlay_object
var tween: Tween

func _init(init_overlay: String, init_color: Color, init_time: float):
	self.overlay = init_overlay
	self.color = init_color
	self.time = init_time
	self.overlay_object = null
	self.tween = null

func execute(tree: SceneTree, mode: ExecutionMode):
	self.overlay_object = FXService.get_layer(overlay)
	
	var original_color = self.overlay_object.color
	if time > 0 and mode == ExecutionMode.PLAY:
		self.tween = tree.create_tween()
		
		self.tween.tween_method(
			self.sample,
			original_color,
			self.color,
			self.time
		)
		
		await self.tween.finished
	else:
		self.overlay_object.color = self.color
	
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

func skip(_tree: SceneTree):
	self.overlay_object.color = self.color
	if self.tween != null:
		self.tween.finished.emit()
		self.tween.kill()
	
