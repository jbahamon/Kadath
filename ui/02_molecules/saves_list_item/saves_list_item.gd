extends MarginContainer

@onready var save_datetime_label: Label = $Button/MarginContainer/VBoxContainer/HBoxContainer/DateAndTime
@onready var time_icon = $Button/MarginContainer/VBoxContainer/HBoxContainer/TimeIcon
@onready var playtime_label: Label = $Button/MarginContainer/VBoxContainer/HBoxContainer/PlayTime
@onready var chapter_name_label: Label = $Button/MarginContainer/VBoxContainer/BasicInfo/VBoxContainer/ChapterName
@onready var save_spot_name_label: Label = $Button/MarginContainer/VBoxContainer/BasicInfo/VBoxContainer/SaveSpotName
@onready var party_info_container: Container = $Button/MarginContainer/VBoxContainer/BasicInfo/PartyInfo
@onready var centerer = $Button/MarginContainer/VBoxContainer/BasicInfo/Centerer

var empty = true

var save_slot
var playtime: String
var save_datetime: String
var chapter_name: String
var save_spot_name: String
var party_info: Array

func _ready():
	self.update_item()
		
func assign_element(element: Dictionary):
	self.empty = element["file"] == null
	self.save_slot = element["index"]
	
	if not self.empty:
		self.save_datetime = element["preview"]["save_datetime"] 
		var play_time_ms = element["preview"]["total_playtime"]
		self.playtime = "%02d:%02d" % [
			floor(play_time_ms / (60 * 60 * 1000)),
			floor(play_time_ms / (60 * 1000)) % 60,
		]
		self.save_spot_name = element["preview"]["save_spot_name"]
		self.party_info = element["preview"]["party"]
		self.chapter_name = "Chapter 1"
	else:
		self.save_datetime = ""
		self.playtime = ""
		self.save_spot_name = ""
		self.party_info = []
		self.chapter_name = "Empty"
		
		
func assign_null(_args: Dictionary):
	self.save_file = {
		"index": -1,
		"file": null
	}
	self.update_item()

func update_item():
	self.save_datetime_label.text = self.save_datetime
	self.playtime_label.text = self.playtime
	self.chapter_name_label.text = self.chapter_name
	self.save_spot_name_label.text = self.save_spot_name
	
	self.party_info_container.visible = not self.empty
	self.time_icon.visible = not self.empty
	self.centerer.visible = self.empty
	self.save_spot_name_label.visible = not self.empty
	
	var i = 0
	
	for child in self.party_info_container.get_children():
		if i < len(self.party_info):
			child.visible = true
			child.get_node("CenterContainer/Icon").texture = Party.party_icons[self.party_info[i]["id"]]
			child.get_node("Label").text = "%s\nLv. %d" % [self.party_info[i]["name"], self.party_info[i]["level"]]
		else:
			child.visible = false
		
		i += 1
	
		

func get_button():
	return $Button

func set_as_disabled(value):
	var color = get_theme_color("font_color_disabled" if value else "font_color", "Button")
	chapter_name_label.add_theme_color_override("font_color", color)
	$Button.disabled = value
