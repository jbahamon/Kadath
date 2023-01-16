extends LocationRoom

func on_enter():
	get_local_scene().play_cutscene("intro")
