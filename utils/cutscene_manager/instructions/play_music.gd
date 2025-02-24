extends CutsceneInstruction

var song_path
var offset: float

func _init(init_song_path, init_offset: float):
	self.song_path = init_song_path
	self.offset = init_offset
	
func execute(_tree: SceneTree, _mode: ExecutionMode):
	if song_path == null:
		MusicService.stop()
		return
	
	MusicService.play_song(load(self.song_path), offset)
		
func _to_string():
	return "play %s at %s" % [self.song_path, self.offset]
