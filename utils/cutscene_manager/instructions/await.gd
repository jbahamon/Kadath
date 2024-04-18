extends CutsceneInstruction

var entity_name: String
var function_name: String
var args: Array

func _init(init_entity_name: String, init_function_name: String, init_args: Array):
	self.entity_name = init_entity_name
	self.function_name = init_function_name
	self.args = init_args
	
func execute(_tree: SceneTree, mode: ExecutionMode):
	var entity: Node = EntitiesService.get_entity(self.entity_name)
	await entity.callv(self.function_name, [mode] + self.args)

func pause(_tree: SceneTree):
	var entity: Node = EntitiesService.get_entity(self.entity_name)
	if entity != null:
		entity.pause_call(self.function_name)
	
func resume(_tree: SceneTree):
	var entity: Node = EntitiesService.get_entity(self.entity_name)
	if entity != null:
		entity.resume_call(self.function_name)
	
func skip(_tree: SceneTree):
	var entity: Node = EntitiesService.get_entity(self.entity_name)
	if entity != null:
		entity.skip_call(self.function_name)
	
func _to_string():
	return "call %s.%s(%s)" % [self.entity_name, self.function_name, self.args]
