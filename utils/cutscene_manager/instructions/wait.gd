extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var time: float

func _init(time: float):
	self.time = time
	
func execute(cutscene_manager):
	var local_scene: LocalScene = cutscene_manager.local_scene
	yield(local_scene.get_tree().create_timer(time), "timeout")

func str():
	return "wait %f" % self.time
