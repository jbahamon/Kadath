extends CanvasLayer

@export var transition_time: float = 1.0

var current_timer = null

# Called when the node enters the scene tree for the first time.
func narrate(text, duration):
	self.visible = true
	$VBox/Margin/NarrationText.text = text
	
	self.current_timer = get_tree().create_timer(duration, false)
	await self.current_timer.timeout
	
	self.current_timer = null
	self.visible = false
	
func skip():
	if self.current_timer != null:
		self.current_timer.timeout.emit()
