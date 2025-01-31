extends CutsceneInstruction

var entity_name_or_entity

func _init(init_entity_name_or_entity):
	self.entity_name_or_entity = init_entity_name_or_entity

func execute(_tree: SceneTree, _mode: ExecutionMode):
	var new_parent
	if self.entity_name_or_entity is String:
		new_parent = EntitiesService.get_entity(self.entity_name_or_entity) 
	else:
		new_parent = self.entity_name_or_entity
	var proxy: PlayerProxy = EntitiesService.proxy
	
	proxy.set_target(new_parent)

func _to_string():
	return "assign_proxy %s" % self.entity_name_or_entity
