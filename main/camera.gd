extends Camera2D

onready var shake = $ScreenShake

func shake(duration = 0.5, frequency = 10, amplitude = Vector2(16, 16), priority = 0):
	var ret = shake.start(duration, frequency, amplitude, priority)
	
	if ret is GDScriptFunctionState:
		yield(ret, "completed")
	else:
		return ret
