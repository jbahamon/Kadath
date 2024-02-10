extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var dialog_id
var branch_selector

func _init(init_dialog_id: String):
	self.dialog_id = init_dialog_id
	
func execute(_tree: SceneTree):
	await DialogService.open_dialog(self.dialog_id)

func _to_string():
	return "start_dialog %s" % self.dialog_id
