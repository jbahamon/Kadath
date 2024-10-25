extends LocationRoom

@export var hit: Hit

func _input(event):
	if event.is_action_pressed("ui_accept"): 
		
		CutsceneService.play_custom_cutscene([
			"ASSIGN_PROXY NONE",
			"AWAIT ROOM do_hit",
			"WAIT 1",
			"ASSIGN_PROXY PARTY"
		]) 

func on_enter():
	EntitiesService.get_proxy().set_orientation(Vector2.DOWN)
	
func do_hit(_mode):
	await EntitiesService.get_active_party_members()[0].battler.take_hit(hit)
		
		
