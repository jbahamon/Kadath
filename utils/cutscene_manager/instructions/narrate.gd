extends CutsceneInstruction

var dialogue_id
var duration

func _init(init_dialogue_id: String, init_duration: float):
	self.dialogue_id = init_dialogue_id
	self.duration = init_duration
	
func execute(_tree: SceneTree, mode: ExecutionMode):
	if mode == ExecutionMode.PLAY:
		await DialogueService.narrate(
			self.dialogue_id,
			self.duration
		)

func _to_string():
	return "narrate %s for %f" % [self.dialogue_id, self.duration]

func skip(_tree: SceneTree):
	DialogueService.skip_narration()
