extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

var movement_param
var mode: String
var position: Vector2
var time: float

func _init(init_movement_param, init_mode, init_time):
	self.movement_param = init_movement_param
	self.mode = init_mode	
	self.time = init_time

func execute(tree: SceneTree):
	match self.mode:
		"target_entity":
			var entity = EntitiesService.get_entity(self.movement_param)
			self.position = entity.global_position	
		"target_position":
			self.position = movement_param
		"displacement":
			self.position = CameraService.get_camera_global_position() + self.movement
		
	var tween = tree.create_tween()
	
	tween.interpolate_property(
		CameraService.get_camera(), 
		"global_position", 
		CameraService.get_camera_global_position(),
		self.position,
		self.time
	)
	
	await tween.finished
	
func _to_string():
	return "move_camera to %s in %f" % [str(self.position), self.time]
