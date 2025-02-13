extends Node

var Shaker = preload("res://utils/shaker.gd")

var sfx_player: AudioStreamPlayer
var spatial_sfx_player: AudioStreamPlayer2D
var DecayMode = Shaker.DecayMode
var layers: Dictionary

func initialize(init_layers: Dictionary, player: AudioStreamPlayer, spatial_player: AudioStreamPlayer2D):
	self.layers = init_layers
	self.sfx_player = player
	self.spatial_sfx_player = spatial_player
	
func exit():
	self.layers = {}

func get_layer(layer_id: String):
	return self.layers.get(layer_id)

func env_shake(duration: float, amplitude: Vector2, time_scale_factor: float):
	if not SettingsService.enable_screen_shake:
		amplitude = Vector2.ZERO
		
	return self.shake(CameraService.camera, duration, amplitude, time_scale_factor, Shaker.DecayMode.LINEAR)
	
func shake(object: Node, duration: float, amplitude: Vector2, time_scale_factor: float, decay_mode):
	var shaker = Shaker.new()
	object.add_child(shaker)
	
	if object == CameraService.camera and not SettingsService.enable_screen_shake:
		amplitude = Vector2.ZERO
	shaker.start(duration, amplitude, time_scale_factor, decay_mode)
	return shaker

func play_sfx(sound: AudioStream):
	self.sfx_player.stream = sound
	self.sfx_player.play()

func play_sfx_at(sound: AudioStream, position: Vector2):
	self.spatial_sfx_player.stream = sound
	self.spatial_sfx_player.position = Vector2.ZERO
	self.spatial_sfx_player.play()
