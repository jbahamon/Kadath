extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var dialog_id
var duration

func _init(init_dialog_id: String, init_duration: float):
	self.dialog_id = init_dialog_id
	self.duration = init_duration
	
func execute(_tree: SceneTree):
	await DialogService.narrate(
		self.dialog_id,
		self.duration
	)

func _to_string():
	return "narrate %s for %f" % [self.dialog_id, self.duration]
