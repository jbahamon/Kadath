extends Node

var player: AudioStreamPlayer

var current_song: AudioStream = null
func initialize(init_player: AudioStreamPlayer):
	self.player = init_player
	
func play_song(song: AudioStream, position: float = 0.0):
	if song == current_song:
		return

	self.current_song = song
	
	if song != null:
		player.stream = self.current_song
		player.play(position)
	else:
		player.stop()

func stop():
	self.current_song = null
	player.stop()
	
