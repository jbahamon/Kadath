extends LocationRoom

@export var hit: Hit

func _input(event):
	if event.is_action_pressed(&"ui_accept"): 
		
		CutsceneService.play_custom_cutscene([
			"ASSIGN_PROXY NONE",
			"WAIT 1",
			"ASSIGN_PROXY PARTY"
		]) 

func on_enter():
	EntitiesService.proxy.set_orientation(Vector2.DOWN)
	
		
