extends Area2D

func _on_CutsceneTrigger_body_entered(body):
	if not body is PlayerProxy:
		return
	
	CutsceneService.play_cutscene("arden_found")
