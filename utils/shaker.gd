extends Node

signal shake_finished

enum DecayMode {
	LINEAR,
	NONE
}

var parent: Node
var target: StringName
var base_offset: Vector2
var duration: float

var noise : FastNoiseLite 

var amplitude: Vector2
var decay: float

var trauma := 0.0
var time = 0
var time_scale = 500

func _init() -> void:
	self.noise = FastNoiseLite.new()
	self.set_process(false)
	
func _process(delta):
	time += delta
	if trauma <= 0 or time >= duration:
		self.shake_finished.emit()
		self.time = 0
		self.set_process(false)
	else:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake(): 
	var amt = pow(trauma, 2)
	
	if target == &"offset":
		parent.offset.x = base_offset.x + amplitude.x * amt * noise.get_noise_2d(time * time_scale, 0)
		parent.offset.y = base_offset.x +amplitude.y * amt * noise.get_noise_2d(0, time * time_scale)
	else:
		parent.position.x = base_offset.x + amplitude.x * amt * noise.get_noise_2d(time * time_scale, 0)
		parent.position.y = base_offset.x +amplitude.y * amt * noise.get_noise_2d(0, time * time_scale)
		
func start(duration: float, shake_amplitude: Vector2, time_scale_factor: float, decay_mode: DecayMode):
	self.parent = get_parent()
	self.target = &"offset" if "offset" in self.parent else &"position"
	self.base_offset = self.parent.get(self.target)
	self.duration = duration
	self.time_scale = 500 * time_scale_factor
	self.noise.seed = randi()
	self.decay = 1.0/duration if decay_mode == DecayMode.LINEAR else 0
	self.amplitude = shake_amplitude
	self.trauma = 1.0
	
	self.set_process(true)
	self.connect("shake_finished", self._on_end, CONNECT_ONE_SHOT)
	return self.shake_finished

func _on_end():
	if target == &"offset":
		self.parent.offset = base_offset
	else:
		self.parent.position = base_offset
		
	if self.parent != null:
		self.parent.remove_child(self)
	self.queue_free()
	
func pause():
	self.set_process(false)
	
func resume():
	self.set_process(true)
	
func skip():
	self.trauma = 0.0
	if self.target == &"offset":
		self.parent.offset = base_offset
	else:
		self.parent.position = base_offset
		
	self.shake_finished.emit()
	self.time = 0
	self.set_process(false)
	if self.parent != null:
		self.parent.remove_child(self)
	self.queue_free()
