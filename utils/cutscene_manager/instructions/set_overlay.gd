extends CutsceneInstruction

var overlay: String
var color: Color

func _init(init_overlay: String, init_color: Color):
	self.overlay = init_overlay
	self.color = init_color

func execute(_tree: SceneTree, _mode: ExecutionMode):
	FXService.get_layer(self.overlay).color = self.color

func _to_string():
	return "set_overlay to %s" % str(self.color)
