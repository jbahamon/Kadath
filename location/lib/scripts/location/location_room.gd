extends TileMap

class_name LocationRoom

@export var clear_color = Color.BLACK


func on_enter():
	await CutsceneService.play_custom_cutscene([
		"SET_OVERLAY MIX TO (0,0,0,1.0)",
		"SET_CAMERA (0,0)",
		"SET_OVERLAY MIX TO (0, 0, 0, 1)",
		"SET_OVERLAY ADD TO (0, 0, 0, 1)",
		"NARRATE narration_1 FOR 0.5",
		"FADE_OVERLAY MIX TO (0,0,0,0) IN 0.5"
	])
