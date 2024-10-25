extends Node

const FadeOverlay = preload("res://utils/cutscene_manager/instructions/fade_overlay.gd")

var current_location: Location = null
var current_room: LocationRoom = null
var world: Node
var prev_proxy_mode = PlayerProxy.ProxyMode.NOT_THERE

func _init():
	self.add_to_group("save")

func initialize(init_world: Node):
	self.world = init_world

func exit():
	current_location = null
	current_room = null

func get_world():
	return self.world
	
func get_room() -> LocationRoom:
	return current_room

func get_location() -> Location:
	return current_location

func update_whereabouts(
	location_id: String, 
	room_id: String,
	target_position: Vector2, 
	target_orientation: Vector2,
	fade: bool,
	end_proxy_state = null
	) -> void:
	
	var location_path = "res://location/%s/location.tres" % location_id
	var old_location = current_location
	var old_room = current_room
	
	if (old_location != null and location_id == old_location.location_id and
		old_room != null and room_id == old_room.room_id):
		return
	
	var was_input_enabled = InputService.is_input_enabled()
	
	InputService.set_input_enabled(false)
	
	self.pop_proxy()
	
	if fade:
		LayersService.get_layer("MIX").color = Color(0,0,0,0)
		if old_location != null and old_room != null:
			await self.fade_out()
	
	if old_location == null or location_id != old_location.location_id:
		
		var new_location: Location = load(location_path)
		new_location.load_rooms()
	
		if old_location != null:
			old_location.free_rooms()

		current_location = new_location
		DialogueService.load_location_dialogues(new_location)

	var room_moved = self.move_to_room(room_id, target_position, target_orientation)
	
	if room_moved:
		EntitiesService.on_enter_room()
		
	self.push_proxy(target_position, target_orientation, end_proxy_state)
	
	if fade:
		await self.fade_in()
	
	if room_moved:
		current_room.on_enter()
		
	InputService.set_input_enabled(was_input_enabled)
	
	
func move_to_room(
	room_id: String,
	target_position: Vector2, 
	target_orientation: Vector2,
) -> bool:
	var room = current_location.instantiate_room(room_id)
	
	if current_room != null and current_room == room:
		return false
	
	if current_room != null:
		EntitiesService.on_exit_room()
		world.remove_child(world.get_child(0))
		current_room.queue_free()
	
	world.add_child(room)
	world.move_child(room, 0)
	current_room = room
	
	for child in room.get_children():
		if child is AnimatedSprite2D:
			child.set_animation("default")
			child.play()
	
	room.setup()
	
	var clear_bg = LayersService.get_layer("CAMERA_BG")
	clear_bg.color = room.clear_color
	
	CameraService.update_camera_bounds(
		current_room.position,
		current_room.get_used_rect(),
		current_room.tile_set.tile_size
	)
	
	return true
	
func pop_proxy():
	var proxy: PlayerProxy = EntitiesService.get_proxy()
	self.prev_proxy_mode = proxy.current_mode
	proxy.set_mode(PlayerProxy.ProxyMode.NOT_THERE)

func push_proxy(
	target_position: Vector2, 
	target_orientation: Vector2,
	end_proxy_state,
):
	var proxy: PlayerProxy = EntitiesService.get_proxy()
	var proxy_target = proxy.target
	var proxy_name = proxy_target.name if proxy_target != null else null
	var new_proxy_target = null
	
	proxy.position = target_position
	proxy.set_orientation(target_orientation)
	
	if proxy_name != null and proxy.current_target_type == PlayerProxy.TargetType.OTHER:
		new_proxy_target = EntitiesService.get_entity(proxy_name)
		proxy.set_target(new_proxy_target)
	elif proxy.current_target_type == PlayerProxy.TargetType.PARTY:
		var party = EntitiesService.get_party()
		party.on_proxy_enter(proxy)
	
	await get_tree().process_frame
	proxy.set_mode(end_proxy_state if end_proxy_state != null else self.prev_proxy_mode)


func load_game_data(save_data: SaveData) -> void:
	await EnvironmentService.update_whereabouts(
		save_data.data["location"], 
		save_data.data["room"],
		Vector2.ZERO,
		Vector2.DOWN,
		true
	)

func save(save_data: SaveData) -> void:
	save_data.data["location"] = self.current_location.location_id
	save_data.data["room"] = self.current_room.room_id
	
func get_sub_viewport() -> SubViewport:
	return self.world.get_parent()

func fade_in():
	await FadeOverlay.new("MIX", Color(0,0,0,0), 0.4).execute(get_tree(), FadeOverlay.ExecutionMode.PLAY)
	
func fade_out():
	LayersService.get_layer("MIX").color = Color(0,0,0,0)
	await FadeOverlay.new("MIX", Color.BLACK, 0.4).execute(get_tree(), FadeOverlay.ExecutionMode.PLAY)
	
