extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var dialog_id
var branch_selector

func _init(init_dialog_id: String, init_branch_selector: String):
	self.dialog_id = init_dialog_id
	self.branch_selector = init_branch_selector
	
func execute(_tree: SceneTree):
	await DialogService.open_dialog(
		self.dialog_id,
		EntitiesService.get_entity(self.branch_selector)
			if self.branch_selector != null 
			else null
	)

func _to_string():
	return "start_dialog %s from %s" % [self.dialog_id, self.branch_selector]
