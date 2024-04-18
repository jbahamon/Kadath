extends CutsceneInstruction

var timer = null
var time

func _init(init_time: float):
	self.time = init_time
	self.timer = null
	
func execute(tree: SceneTree, mode: ExecutionMode):
	if mode == ExecutionMode.PLAY:
		self.timer = tree.create_timer(self.time, false)
		await self.timer.timeout
	
func _to_string():
	return "wait %f" % self.time

func skip(_tree: SceneTree):
	if self.timer != null:
		self.timer.timeout.emit()
