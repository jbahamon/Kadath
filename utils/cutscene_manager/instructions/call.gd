extends CutsceneInstruction

var entity_name: String
var function_name: String
var args: Array

func _init(init_entity_name: String, init_function_name: String, init_args: Array):
	self.entity_name = init_entity_name
	self.function_name = init_function_name
	self.args = init_args
	
func execute(_tree: SceneTree, _mode: ExecutionMode):
	var entity: Node = EntitiesService.get_entity(self.entity_name)
	entity.callv(self.function_name, self.args)

func _to_string():
	return "call %s.%s(%s)" % [self.entity_name, self.function_name, self.args]
