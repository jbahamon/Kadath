extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var overlay: String
var color: Color

func _init(init_overlay: String, init_color: Color):
	self.overlay = init_overlay
	self.color = init_color

func execute(_tree: SceneTree):
	LayersService.get_layer(self.overlay).color = self.color

func _to_string():
	return "set_overlay to %s" % str(self.color)
