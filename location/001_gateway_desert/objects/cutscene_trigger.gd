extends Area2D

func get_local_scene():
	return self.get_node('./../../..')

func _on_CutsceneTrigger_body_entered(body):
	if not body is PlayerProxy:
		return
	
	self.get_local_scene().play_cutscene("arden_found")
