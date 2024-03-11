extends Camera2D

@onready var screen_shake = $ScreenShake

func shake(duration: float, amplitude: Vector2):
	return screen_shake.start(duration, amplitude)
	
