extends Node

signal shake_finished

@onready var camera = get_parent()
@export var noise : FastNoiseLite 

var amplitude := Vector2(16, 16) 
var decay := 0.1 # trauma lost per second

var trauma := 0.0
var time = 0
var time_scale = 500

func _ready():
	self.set_process(false)
	
func _process(delta):
	time += delta
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		self.shake_finished.emit()
		self.time = 0
		self.set_process(false)

func shake(): 
	var amt = pow(trauma, 2)
	camera.offset.x = amplitude.x * amt * noise.get_noise_2d(time * time_scale, 0)
	camera.offset.y = amplitude.y * amt * noise.get_noise_2d(0, time * time_scale)
	
func start(duration: float, shake_amplitude: Vector2):
	self.noise.seed = randi()
	self.decay = 1.0/duration
	self.amplitude = shake_amplitude
	self.trauma = 1.0
	self.set_process(true)
	return self.shake_finished

func pause():
	self.set_process(false)
	
func resume():
	self.set_process(true)
	
func skip():
	self.trauma = 0.0
	self.shake_finished.emit()
	self.time = 0
	self.set_process(false)
