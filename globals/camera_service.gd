extends Node

var camera: Camera2D

func initialize(init_camera: Camera2D):
	self.camera = init_camera

func update_camera_bounds(origin: Vector2, tilemap_limits: Rect2i, tile_size: Vector2i):
	
	var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var room_width = (tilemap_limits.end.x - tilemap_limits.position.x) * tile_size.x
	
	if room_width < screen_width:
		var mid_point = int(origin.x + (tilemap_limits.position.x + tilemap_limits.end.x) * tile_size.x / 2.0)
		self.camera.limit_left = int(mid_point - screen_width/2.0)
		self.camera.limit_right = int(mid_point + screen_width/2.0)
	else:
		self.camera.limit_left = int(origin.x + tilemap_limits.position.x * tile_size.x)
		self.camera.limit_right = int(origin.x + tilemap_limits.end.x * tile_size.x)
	
	var screen_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var room_height = (tilemap_limits.end.y - tilemap_limits.position.y) * tile_size.y
	
	if room_height < screen_height:
		var mid_point = origin.y + (tilemap_limits.position.y + tilemap_limits.end.y) * tile_size.y / 2.0
		self.camera.limit_top = mid_point - screen_height/2.0
		camera.limit_bottom = mid_point + screen_height/2.0
	else:
		camera.limit_top = origin.y + tilemap_limits.position.y * tile_size.y
		camera.limit_bottom =  origin.y + tilemap_limits.end.y * tile_size.y

	camera.align()
	
func assign_camera(target: Node):
	var old_position = camera.position
	var old_parent_position = Vector2.ZERO
	
	var camera_parent = self.camera.get_parent()
			
	if camera_parent == target:
		return camera_parent

	if camera_parent != null:
		old_parent_position = camera_parent.position
		camera_parent.remove_child(camera)
		
	target.add_child(camera)
	
	if target == EnvironmentService.get_world():
		camera.position = old_parent_position + old_position
	else:
		camera.position = old_parent_position + old_position - target.position
		
	camera.align()
	
	return camera_parent

func set_camera_position(position: Vector2):
	camera.position = position
	camera.align()
	
func get_camera():
	return camera
	
func get_camera_position():
	return camera.position
	
func get_camera_global_position():
	return camera.global_position
