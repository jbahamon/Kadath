extends Camera2D

@onready var screen_shake = $ScreenShake

func shake(mode: CutsceneInstruction.ExecutionMode, duration: float, amplitude: Vector2):
	match mode:
		CutsceneInstruction.ExecutionMode.PLAY:
			return self.screen_shake.start(duration, amplitude)
	
	
func pause_call(function_name: String):
	match function_name:
		"shake":
			self.screen_shake.pause()

func resume_call(function_name: String):
	match function_name:
		"shake":
			self.screen_shake.resume()

func skip_call(function_name: String):
	match function_name:
		"shake":
			self.screen_shake.skip()
