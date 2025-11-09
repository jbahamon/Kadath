extends Node

var Shaker = preload("res://utils/shaker.gd")

var DecayMode = Shaker.DecayMode
var layers: Dictionary

func initialize(init_layers: Dictionary):
	self.layers = init_layers
	
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
	var player = AudioStreamPlayer.new()
	player.bus = &"SFX"
	self.get_tree().root.add_child(player)
	player.stream = sound
	player.finished.connect(player.queue_free)
	player.play()
	return player

func play_sfx_at(sound: AudioStream, position: Vector2):
	var player = AudioStreamPlayer2D.new()
	player.bus = &"SFX"
	EnvironmentService.world.add_child(player)
	player.stream = sound
	player.position = position
	player.finished.connect(player.queue_free)
	player.play()
	return player

func play_gfx_at(effect_frames: SpriteFrames, position: Vector2, offset: Vector2, duration = -1.0):
	var effect = AnimatedSprite2D.new()
	var room = EnvironmentService.current_room
	effect.sprite_frames = effect_frames
	room.add_child(effect)
	effect.global_position = position
	effect.offset = offset
	effect.play(&"default")
	
	if duration > 0:
		await get_tree().create_timer(duration).timeout
	else:
		await effect.animation_finished
	
	room.remove_child(effect)
	
	effect.visible = false
	effect.queue_free()
