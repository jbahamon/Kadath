extends Area2D

@export var limit: float

func _on_body_entered(body):
	if not body is PlayerProxy:
		return
		
	self.call_deferred("push_back", body.position, body.walk_speed)
	
func push_back(original_position: Vector2, speed: float):
	var target_position = Vector2(original_position.x, limit)
	await CutsceneService.play_custom_cutscene([
		"LOOK PROXY DOWN",
		"PLAY_ANIM PROXY idle",
		"START_DIALOGUE pushing_barrier SOURCE NONE",
		"LOOK PROXY UP",
		"WALK PROXY TO ({x},{y}) AT {speed}".format({
			"x": target_position.x,
			"y": target_position.y,
			"speed": speed
		}),
	], {"pausable": false})
