extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var time: float

func _init(init_time: float):
	self.time = init_time
	
func execute(tree: SceneTree):
	await tree.create_timer(time).timeout

func _to_string():
	return "wait %f" % self.time
