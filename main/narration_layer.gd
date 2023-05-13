extends CanvasLayer

@export var transition_time: float = 1.0

# Called when the node enters the scene tree for the first time.
func narrate(text, duration):
	self.visible = true
	$VBox/Margin/NarrationText.text = text
	await get_tree().create_timer(duration).timeout
	self.visible = false
	
