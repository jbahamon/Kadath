extends LocationRoom


func _on_north_gate_body_entered(body):
	if not body is PlayerProxy:
		return
	CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/end.cutscene")
