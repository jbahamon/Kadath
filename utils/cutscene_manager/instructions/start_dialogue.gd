extends CutsceneInstruction

var dialogue_id
var alignment

func _init(init_dialogue_id: String, init_alignment: DialogueService.Alignment):
	self.dialogue_id = init_dialogue_id
	self.alignment = init_alignment
	
func execute(_tree: SceneTree, mode: ExecutionMode):
	if mode == ExecutionMode.PLAY:
		await DialogueService.open_dialogue(self.dialogue_id, alignment)

func _to_string():
	return "start_dialogue %s" % self.dialogue_id

func pause(_tree: SceneTree):
	DialogueService.pause_dialogue()

func resume(_tree: SceneTree):
	DialogueService.resume_dialogue()

func skip(_tree: SceneTree):
	DialogueService.skip_dialogue()
	
