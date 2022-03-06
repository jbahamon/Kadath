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

func _ready() -> void:
	player_proxy.set_party(party)
	
	if PlayerVars.loaded_slot >= 0:
		SaveManager.load(PlayerVars.loaded_slot)
		PlayerVars.loaded_slot = -1
	else:
		self.update_whereabouts(
			PlayerVars.starting_location_name, 
			PlayerVars.starting_room_name,
			Vector2.ZERO,
			Vector2.DOWN,
			false
		)
		yield(cutscene_manager.play_cutscene("intro"), "completed")
	
func get_room_object(object_name: String):
	if current_room != null:
		return current_room.get_node("./" + object_name)
	else:
		return null

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
	
	dialog_box.set_default_source(source.display_name)
	
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
	yield(self.cutscene_manager.play_cutscene(cutscene_name), "completed")
	
func start_cutscene():
	self.set_process_unhandled_input(false)
	player_proxy.set_process_unhandled_input(false)
	world.set_process_unhandled_input(false)

func end_cutscene():
	self.set_process_unhandled_input(true)
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
	
	self.start_cutscene()
	
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
	
	self.move_to_room(room_id, target_position, target_orientation)

	if fade:
		cutscene.play("fade_from_black")
		yield(cutscene, "animation_finished")
	
	self.end_cutscene()
	
	
func move_to_room(
	room_id: String,
	target_position: Vector2, 
	target_orientation: Vector2
) -> void:
	var room = current_location.get_room(room_id)
	var proxy_target = player_proxy.get_target()
	var proxy_name = proxy_target.name if proxy_target != null else null
	
	if current_room != null and current_room == room:
		return
	
	if current_room != null:
		world.remove_child(world.get_child(0))
	
	world.add_child(room)
	world.move_child(room, 0)
	current_room = room
	
	for child in room.get_children():
		if child is AnimatedSprite:
			child.set_animation("default")
			child.play()
	
	var map_limits = room.get_used_rect()
	var map_cellsize = room.cell_size
	camera.limit_left = map_limits.position.x * map_cellsize.x + room.position.x
	camera.limit_right = map_limits.end.x * map_cellsize.x + room.position.x
	camera.limit_top = map_limits.position.y * map_cellsize.y + room.position.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y + room.position.y
	
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
	
	current_room.on_enter()
