extends Node2D
class_name LocalScene

var StoryReader = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
var talk_speed = 20.0
var strings = { "player": "Arden", "preference": "none" }
var current_location = null


onready var player: Player
onready var world = $World
onready var dialog_box = $SimpleDialogBox
onready var story_reader = StoryReader.new()
onready var menu_popup: Popup = $MenuLayer/MenuPopup
onready var menu = $MenuLayer/MenuPopup/PauseMenu
onready var save_popup = $MenuLayer/SavesPopup

func _ready():
	self.player = PlayerVars.player
	world.add_child(player)
	
	var camera = $Camera2D
	self.remove_child(camera)
	player.add_child(camera)
	
	update_location()
	 
	
func update_location():
	var location_name = PlayerVars.location_name
	var location = load("res://Locations/%s/Maps/%s.tscn" % [location_name, location_name]).instance()
	world.add_child(location)
	world.move_child(location, 0)
			
	current_location = location
	var story = load("res://Locations/%s/Stories/Baked.tres" % current_location.story_name)
	story_reader.read(story)
	
	
func talk(source, dialog_name, from_node_id):
	if not story_reader.has_record_name(dialog_name):
		return
		
	var did = story_reader.get_did_via_record_name(dialog_name)
	var nid = from_node_id
	var pool = PoolStringArray()
	
	while story_reader.has_nid(did, nid):
		
		var text = story_reader.get_text(did, nid).format(strings)
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
				nid = source.get_next_nid(nid, slots)
		
	

func _unhandled_input(event):
	if event.is_action_pressed("ui_menu"):
		menu_popup.popup_centered_ratio(1)


func show_save_menu():
	save_popup.popup_centered_ratio(1)


func _on_menu_popup_hide():
	player.set_process_unhandled_input(true)
	world.set_physics_process(true)
	world.set_process(true)
	world.set_process_unhandled_input(true)
	
	menu.set_process_unhandled_input(false)


func _on_menu_about_to_show():
	player.set_process_unhandled_input(false)
	world.set_physics_process(false)
	world.set_process(false)
	world.set_process_unhandled_input(false)
	
	menu.set_process_unhandled_input(true)

