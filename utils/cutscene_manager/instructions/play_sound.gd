extends CutsceneInstruction

var channel: String
var stream_path: String
var position

var player

func _init(init_stream_path: String, init_channel: String, init_position):
	self.channel = init_channel
	self.stream_path = init_stream_path
	self.position = init_position

func execute(_tree: SceneTree, mode: ExecutionMode):
	if mode != ExecutionMode.PLAY:
		return
	
	var stream = load(self.stream_path)
	match self.channel:
		"SFX":
			if self.position != null:
				self.player = FXService.play_sfx_at(stream, position)
			else:
				self.player = FXService.play_sfx(stream)
		"UI":
			self.player = UIService.play_notification(stream)
		"BGM":
			MusicService.play_song(stream)


func skip(_tree: SceneTree):
	if self.player != null:
		if self.channel == "BGM":
			MusicService.stop()
		else:
			self.player.stop()
			

func _to_string():
	return "play %s through %s" % [self.stream_path, self.channel]
