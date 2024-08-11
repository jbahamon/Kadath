extends CutsceneInstruction

var movement_param
var movement_mode: String
var position: Vector2
var time: float
var tween

func _init(init_movement_param, init_mode, init_time):
	self.movement_param = init_movement_param
	self.movement_mode = init_mode	
	self.time = init_time

func execute(tree: SceneTree, mode: ExecutionMode):
	match self.movement_mode:
		"target_entity":
			var entity = EntitiesService.get_entity(self.movement_param)
			self.position = entity.global_position	
		"target_position":
			self.position = movement_param
		"displacement":
			self.position = CameraService.get_camera_global_position() + self.movement
	
	if self.time > 0 and mode == ExecutionMode.PLAY:
		self.tween = tree.create_tween()
		
		self.tween.tween_property(
			CameraService.get_camera(), 
			"global_position", 
			self.position,
			self.time
		)
	
		await self.tween.finished
	else:
		CameraService.set_camera_position(self.position)
	
func _to_string():
	return "move_camera to %s in %f" % [str(self.position), self.time]

func skip(_tree: SceneTree):
	if self.time > 0:
		CameraService.set_camera_position(self.position)
		if self.tween != null:
			self.tween.finished.emit()
			self.tween.kill()
