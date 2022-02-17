extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var dialog_name
var node_id
var branch_selector

func _init(dialog_name: String, node_id: int, branch_selector: String):
	self.dialog_name = dialog_name
	self.node_id = node_id
	self.branch_selector = branch_selector
	
func execute(cutscene_manager):
	var ret = cutscene_manager.local_scene.open_dialog(
			self.dialog_name,
			self.node_id,
			cutscene_manager.get_entity(self.branch_selector)
				if self.branch_selector != null 
				else cutscene_manager.local_scene
		)
	if ret is GDScriptFunctionState:
		yield(ret, "completed")
	

func str():
	return "start_dialog %s (%d) from %s" % [self.dialog_name, self.node_id, self.branch_selector]
