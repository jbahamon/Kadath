extends Node

var camera: Camera2D = null
var sub_viewport: SubViewport = null

func initialize(init_camera: Camera2D, init_sub_viewport: SubViewport):
	self.camera = init_camera
	self.sub_viewport = init_sub_viewport

func exit():
	self.camera = null
	self.sub_viewport = null

func update_camera_bounds(origin: Vector2, limits: Rect2i):
	var screen_width = sub_viewport.size.x
	var room_width = limits.end.x - limits.position.x
	
	if room_width < screen_width:
		var mid_point = int(origin.x + (limits.position.x + limits.end.x) / 2.0)
		self.camera.limit_left = int(mid_point - screen_width/2.0)
		self.camera.limit_right = int(mid_point + screen_width/2.0)
	else:
		self.camera.limit_left = int(origin.x + limits.position.x)
		self.camera.limit_right = int(origin.x + limits.end.x)
	
	var screen_height = sub_viewport.size.y
	var room_height = limits.end.y - limits.position.y
	
	if room_height < screen_height:
		var mid_point = origin.y + (limits.position.y + limits.end.y)/ 2.0
		self.camera.limit_top = roundi(mid_point - screen_height/2.0)
		camera.limit_bottom = roundi(mid_point + screen_height/2.0)
	else:
		camera.limit_top = int(origin.y + limits.position.y)
		camera.limit_bottom =  int(origin.y + limits.end.y)

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

func get_visible_rect() -> Rect2i:
	var size = self.sub_viewport.size
	var origin
	
	if camera.anchor_mode == camera.ANCHOR_MODE_FIXED_TOP_LEFT:
		origin = camera.global_position
	elif camera.anchor_mode == camera.ANCHOR_MODE_DRAG_CENTER:
		origin = camera.global_position - size/2.0
	
	return Rect2i(origin, size)
