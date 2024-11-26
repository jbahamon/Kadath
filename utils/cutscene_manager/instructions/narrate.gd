extends CutsceneInstruction

var dialogue_id

func _init(init_dialogue_id: String):
	self.dialogue_id = init_dialogue_id
	
func execute(_tree: SceneTree, mode: ExecutionMode):
	if mode == ExecutionMode.PLAY:
		await DialogueService.narrate(
			self.dialogue_id,
		)

func _to_string():
	return "narrate %s" % self.dialogue_id

func skip(_tree: SceneTree):
	DialogueService.skip_narration()
