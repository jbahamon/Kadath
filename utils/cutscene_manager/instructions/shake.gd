extends CutsceneInstruction

var entity_name: String
var duration: float
var amplitude: Vector2
var time_scale_factor: float

var shaker = null

func _init(init_entity_name: String, init_duration: float, init_amplitude: Vector2, init_time_scale_factor: float):
	self.entity_name = init_entity_name
	self.duration = init_duration
	self.amplitude = init_amplitude
	self.time_scale_factor = init_time_scale_factor
	
func execute(_tree: SceneTree, mode: ExecutionMode):
	if mode == ExecutionMode.PLAY:
		var entity = EntitiesService.get_entity(self.entity_name)
		self.shaker = FXService.shake(entity, duration, amplitude, time_scale_factor, FXService.DecayMode.NONE)
		await self.shaker.shake_finished

func skip(_tree: SceneTree):
	if self.shaker != null:
		shaker.skip()

func pause(_tree: SceneTree):
	if self.shaker != null:
		shaker.pause()

func resume(_tree: SceneTree):
	if self.shaker != null:
		shaker.resume()
	
func _to_string():
	return "shake %s" % self.entity_name
