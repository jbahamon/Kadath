extends CutsceneInstruction

var entity_name: String
var position: Array
var speed: float

func _init(init_entity_name: String, init_position: Array, init_speed: float):
	self.entity_name = init_entity_name
	self.position = init_position
	self.speed = init_speed
	
func execute(_tree: SceneTree, mode: ExecutionMode):
	var entity = EntitiesService.get_entity(self.entity_name)
	if self.speed != INF and mode == ExecutionMode.PLAY:
		await entity.move_to(self.position, self.speed)
	else:
		entity.global_position = Vector2(
			position[0] if position[0] != null else entity.global_position.x,
			position[1] if position[1] != null else entity.global_position.y
		)

func skip(_tree: SceneTree):
	var entity = EntitiesService.get_entity(self.entity_name)
	if entity != null:
		entity.skip_move_to()

func _to_string():
	return "move %s to %s at %f" % [self.entity_name, str(self.position), self.speed]
