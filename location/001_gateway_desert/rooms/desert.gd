extends LocationRoom

func on_enter():
	CutsceneService.play_cutscene("intro")
