extends Node2D
class_name LocalScene

var StoryReader = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
var talk_speed = 3
var strings = { "player": "Arden", "preference": "none" }
var current_location = null

onready var ysort = $YSort
onready var player: Player = $YSort/Player
onready var dialog_box: BlockingDialogBox = $BlockingDialogBox
onready var input_box: BlockingInputBox = $BlockingInputBox
onready var list_selection: BlockingListSelection = $BlockingListSelection
onready var story_reader = StoryReader.new()


func _ready():
	player.position =  PlayerVars.starting_position
	var location_name = PlayerVars.starting_location_name
	load_location(location_name)
	 
	
func load_location(location_name):
	var location = load("res://World/%s/%s.tscn" % [location_name, location_name]).instance()
	ysort.add_child(location)
	ysort.move_child(location, 0)
	
	current_location = location
	var story = load("res://Stories/Baked/%s.tres" % current_location.story_name)
	story_reader.read(story)
	
	
func talk(dialog_name):
	var did = story_reader.get_did_via_record_name(dialog_name)
	var pool = PoolStringArray()
	for nid in story_reader.get_nids(did):
		var text = story_reader.get_text(did, nid)
		pool.append(text.format(strings))
		
	var total_text = pool.join("[break]")
	dialog_box.append_text(total_text, len(total_text)/talk_speed)
	yield(dialog_box, "box_hidden")
