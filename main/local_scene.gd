extends Node
class_name LocalScene

var StoryReader = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
var talk_speed = 20.0
var current_location: LocationMap = null

onready var party = $World/Party
onready var player_proxy: PlayerProxy = $World/PlayerProxy
onready var world = $World
onready var dialog_box = $SimpleDialogBox
onready var story_reader = StoryReader.new()
onready var menu_popup: Popup = $MenuLayer/MenuPopup
onready var menu = $MenuLayer/MenuPopup/PauseMenu
onready var save_popup = $MenuLayer/SavesPopup


func _ready() -> void:
	player_proxy.set_party(party)
	
	if PlayerVars.loaded_slot >= 0:
		SaveManager.load(PlayerVars.loaded_slot)
		PlayerVars.loaded_slot = -1
	else:
		self.update_location(PlayerVars.starting_location_name)


func talk(source, dialog_name, from_node_id) -> void:
	if not story_reader.has_record_name(dialog_name):
		return
		
	var did = story_reader.get_did_via_record_name(dialog_name)
	var nid = from_node_id
	var pool = PoolStringArray()
	
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
				nid = story_reader.get_nid_from_slot(did, nid, slot)
		
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		menu_popup.popup_centered_ratio(1)


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
	save_data.data['location'] = self.current_location.save_name


func load(save_data: SaveData) -> void:
	update_location(save_data.data['location'])

	
func update_location(location_name) -> void:
	var location_path = ("res://location/%s/map/%s.tscn" % 
						 [location_name, location_name])
	var location = load(location_path).instance()
	world.add_child(location)
	world.move_child(location, 0)
	
	for child in location.get_children():
		if child is AnimatedSprite:
			child.set_animation("default")
			child.play()
			
	current_location = location
	story_reader.read(current_location.story)
	
