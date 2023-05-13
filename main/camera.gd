extends Camera2D

@onready var shake = $ScreenShake

func do_shake(duration = 0.5, frequency = 10, amplitude = Vector2(16, 16), priority = 0):
	await shake.start(duration,frequency, amplitude,priority)
	
