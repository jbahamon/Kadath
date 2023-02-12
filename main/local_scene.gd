extends Node2D
class_name LocalScene

var StoryReader = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
var talk_speed = 20.0
var current_location: Location = null
var current_room: LocationRoom = null

onready var camera = $World/PlayerProxy/Camera2D
onready var party = $World/Party
onready var player_proxy: PlayerProxy = $World/PlayerProxy
onready var world = $World
onready var dialog_box = $SimpleDialogBox
onready var story_reader = StoryReader.new()
onready var menu_popup: Popup = $MenuLayer/MenuPopup
onready var menu = $MenuLayer/MenuPopup/PauseMenu
onready var save_popup = $MenuLayer/SavesPopup
onready var cutscene = $LocalCutscene
onready var cutscene_manager = $CutsceneManager

onready var popup_layer = $PopupLayer

var display_name = null
var block_input = false

var elements_hidden_for_battle = []

func _ready() -> void:
	player_proxy.set_party(party)
	
	if PlayerVars.loaded_slot >= 0:
		SaveManager.load(PlayerVars.loaded_slot)
		PlayerVars.loaded_slot = -1
	else:
		self.update_whereabouts(
			PlayerVars.starting_location_name, 
			PlayerVars.starting_room_name,
			Vector2(0, -64), #Vector2.ZERO,
			Vector2.DOWN,
			false
		)
	
func get_room_object(object_name: String):
	if current_room == null:
		return null
		
	var object = current_room.get_node_or_null("./" + object_name)
	
	if object != null:
		return object
		
	object = party.get_node_or_null("./" + object_name)
	return object

func get_overlay(overlay: String):
	match overlay:
		"MIX": return $OverlayLayer/Mix
		"ADD": return $OverlayLayer/Add
		_: return null

func open_dialog(dialog_name: String, node_id: int, source) -> void:
	if not story_reader.has_record_name(dialog_name):
		return
		
	var did = story_reader.get_did_via_record_name(dialog_name)
	var nid = node_id
	var pool = PoolStringArray()
	
	if source != null:
		dialog_box.set_default_source(source.display_name)
	else:
		dialog_box.set_default_source("None")
	
	while story_reader.has_nid(did, nid):
		
		var text = story_reader.get_text(did, nid).format(PlayerVars.strings)
		pool.append(text)
		
		var slots = story_reader.get_slots(did, nid)
		
		match len(slots):
			0: 
				dialog_box.queue_texts(pool)
				yield(dialog_box, "dialog_closed")
				return
			1: 
				nid = story_reader.get_nid_from_slot(did, nid, slots[0])
			_: 
				dialog_box.queue_texts(pool)
				pool = PoolStringArray()
				var slot = source.get_slot(nid, slots)
				
				if slot is GDScriptFunctionState:
					slot = yield(slot, "completed")
				
				nid = story_reader.get_nid_from_slot(did, nid, slot)
		
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		menu_popup.popup_centered_ratio(1)

func show_popup(popup: Popup):
	self.popup_layer.add_child(popup)
	popup.popup()

func play_cutscene(cutscene_name: String):
	yield(self.cutscene_manager.play_cutscene_from_file(cutscene_name), "completed")
	
func play_custom_cutscene(cutscene_instructions: Array):
	yield(self.cutscene_manager.play_cutscene_from_array(cutscene_instructions), "completed")
	
func disable_inputs():
	self.set_process_unhandled_input(false)
	player_proxy.set_process(false)
	player_proxy.set_physics_process(false)
	player_proxy.set_process_unhandled_input(false)
	
	world.set_process_unhandled_input(false)

func enable_inputs():
	self.set_process_unhandled_input(true)
	player_proxy.set_process(true)
	player_proxy.set_physics_process(true)
	player_proxy.set_process_unhandled_input(true)
	world.set_process_unhandled_input(true)

func show_save_menu() -> void:
	save_popup.popup_centered_ratio(1)

func _on_menu_popup_hide() -> void:
	player_proxy.set_process_unhandled_input(true)
	world.set_physics_process(true)
	world.set_process(true)
	world.set_process_unhandled_input(true)
	menu.set_process_unhandled_input(false)

func _on_menu_about_to_show() -> void:
	player_proxy.set_process_unhandled_input(false)
	world.set_physics_process(false)
	world.set_process(false)
	world.set_process_unhandled_input(false)
	menu.initialize(party)
	menu.set_process_unhandled_input(true)

func save(save_data: SaveData) -> void:
	save_data.data["location"] = self.current_location.location_id
	save_data.data["room"] = self.current_room.room_id

func load(save_data: SaveData) -> void:
	update_whereabouts(
		save_data.data["location"], 
		save_data.data["room"],
		Vector2.ZERO,
		Vector2.DOWN,
		true
	)
	
func update_whereabouts(
	location_id: String, 
	room_id: String,
	target_position: Vector2, 
	target_orientation: Vector2,
	fade: bool
	) -> void:
	
	var location_path = "res://location/%s/location.tres" % location_id
	var old_location = current_location
	var old_room = current_room
	
	fade = fade and old_location != null
	
	if (old_location != null and location_id != old_location.location_id and
		old_room != null and room_id == old_room.room_id):
		return
	
	var were_inputs_disabled = not self.is_processing_unhandled_input()
	
	if not were_inputs_disabled:
		self.disable_inputs()
	
	if fade and old_location != null and old_room != null:
		cutscene.play("fade_to_black")
	
	if old_location == null or location_id != old_location.location_id:
		
		var new_location: Location = load(location_path)
		new_location.load_rooms()
	
		if old_location != null:
			old_location.free_rooms()

		current_location = new_location
		assert(current_location.story != null)
		story_reader.read(current_location.story)

	if fade and old_location != null and old_room != null:
		yield(cutscene, "animation_finished")
	
	var room_moved = self.move_to_room(room_id, target_position, target_orientation)

	if fade:
		cutscene.play("fade_from_black")
		yield(cutscene, "animation_finished")
	
	if not were_inputs_disabled:
		self.enable_inputs()
	
	if room_moved:
		current_room.on_enter()
	
func move_to_room(
	room_id: String,
	target_position: Vector2, 
	target_orientation: Vector2
) -> bool:
	var room = current_location.get_room(room_id)
	var proxy_target = player_proxy.target
	var proxy_name = proxy_target.name if proxy_target != null else null
	
	if current_room != null and current_room == room:
		return false
	
	if current_room != null:
		world.remove_child(world.get_child(0))
	
	world.add_child(room)
	world.move_child(room, 0)
	current_room = room
	
	for child in room.get_children():
		if child is AnimatedSprite:
			child.set_animation("default")
			child.play()
	
	var clear_bg = $BGLayer/CameraBG
	clear_bg.color = room.clear_color
	
	self.update_camera_bounds()
	
	var new_proxy_target = null
	
	if proxy_name != null:
		if proxy_name == "Party":
			new_proxy_target = party
		else:
			new_proxy_target = self.get_room_object(proxy_name)
		
		self.player_proxy.set_target(new_proxy_target)
	
	player_proxy.position = target_position
	player_proxy.set_orientation(target_orientation)
	camera.align()
	
	return true

func update_camera_bounds():
	
	var room_limits = current_room.get_used_rect()
	var room_cell_size = current_room.cell_size
	
	var screen_width = ProjectSettings.get_setting("display/window/size/width")
	var room_width = (room_limits.end.x - room_limits.position.x) * room_cell_size.x
	
	if room_width < screen_width:
		var mid_point = current_room.position.x + (room_limits.position.x + room_limits.end.x) * room_cell_size.x / 2
		camera.limit_left = mid_point - screen_width/2
		camera.limit_right = mid_point + screen_width/2
	else:
		camera.limit_left = room_limits.position.x * room_cell_size.x + current_room.position.x
		camera.limit_right = room_limits.end.x * room_cell_size.x + current_room.position.x
	
	var screen_height = ProjectSettings.get_setting("display/window/size/height")
	var room_height = (room_limits.end.y - room_limits.position.y) * room_cell_size.y
	
	if room_height < screen_height:
		var mid_point = current_room.position.y + (room_limits.position.y + room_limits.end.y) * room_cell_size.y / 2
		camera.limit_top = mid_point - screen_height/2
		camera.limit_bottom = mid_point + screen_height/2
	else:
		camera.limit_top = room_limits.position.y * room_cell_size.y + current_room.position.y
		camera.limit_bottom = room_limits.end.y * room_cell_size.y + current_room.position.y
	
func start_battle(non_party_actors: Array, enemy_position: Vector2):
	assert(enemy_position != null)
	
	self.disable_inputs()
	
	var camera_parent = self.camera.get_parent()
	if camera_parent != null:
		camera_parent.remove_child(camera)
	
	self.world.add_child(camera)
	
	var positioning_vars = {
		"current_position": self.camera.position
	}
	
	var actor_names = {}
	for actor in non_party_actors:
		actor_names[actor.name] = true
	
	self.elements_hidden_for_battle = []
	
	for child in world.get_children():
		if (child.is_in_group("npc") and 
			child.visible and
			not actor_names.get(child.name, false)):
			self.elements_hidden_for_battle.append(child)
			child.visible = false

	var proc = self.player_proxy.is_physics_processing()
	$Battle.start(current_room, party, non_party_actors, positioning_vars)
	
func end_battle(player_won: bool):
	
	# Return camera to player proxy
	var camera_parent = self.camera.get_parent()
	if camera_parent != null:
		camera_parent.remove_child(camera)
	
	self.player_proxy.add_child(camera)
	
	# move to game over scene if player lost
	for element in self.elements_hidden_for_battle:
		element.visible = true
	self.elements_hidden_for_battle = []
	self.enable_inputs()



