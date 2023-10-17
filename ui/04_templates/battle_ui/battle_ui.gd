extends MarginContainer

class_name BattleUI

var BattleAction = preload("res://battle/action/battle_action.gd")
var MultiTargetOption = load("res://ui/04_templates/battle_ui/multi_target_option.gd")


@onready var party_status = $VBoxContainer/HBoxContainer/PartyStatus
@onready var options = $VBoxContainer/HBoxContainer/Options
@onready var options_title: Label = $VBoxContainer/HBoxContainer/Options/OptionsTitle/Label
@onready var options_list = $VBoxContainer/HBoxContainer/Options/OptionsList
@onready var options_info = $VBoxContainer/HBoxContainer/Options/OptionsInfo
@onready var options_info_label = $VBoxContainer/HBoxContainer/Options/OptionsInfo/InfoLabel

@onready var timeline_container = $VBoxContainer/Timeline
@onready var timeline = $VBoxContainer/Timeline/PlaceholderTimeline

@onready var info_panel = $VBoxContainer/InfoPanel
@onready var info_label = $VBoxContainer/InfoPanel/InfoLabel

signal option_selected(option)
signal prompt_closed
signal cancel

var options_stack: Array = []
var waiting_for_prompt: bool = false
var all_allies_option = MultiTargetOption.new()
var all_enemies_option = MultiTargetOption.new()

func _init():
	self.all_allies_option.display_name = "All allies"
	self.all_allies_option.targets = []
	self.all_enemies_option.display_name = "All enemies"
	self.all_enemies_option.targets = []

func initialize(party_members: Array):
	party_status.initialize(party_members)
	self.reset_options_stack()
	self.set_info_text(null)
		
func prompt(text: String):
	self.waiting_for_prompt = true
	self.set_info_text(text)
	await self.prompt_closed
	self.waiting_for_prompt = false

func _unhandled_input(event):
	if waiting_for_prompt and (
		event.is_action_pressed("ui_accept") or 
		event.is_action_pressed("ui_cancel")
	):
		self.set_info_text(null)
		emit_signal("prompt_closed")

func reset_options_stack():
	self.options_stack = []

func set_options(new_options):
	self.options_stack.push_back(new_options)
	self.options.visible = true
	options_title.text = new_options["title"]
	options_list.initialize(new_options["options"])
	options_list.on_grab_focus()
	
func on_option_selected(option):
	if option is CompositeBattleOption:
		var new_options = {
			"is_sub_option": true,
			"title": option.get_prompt(),
			"options": option.get_options(),
		}
		self.set_options(new_options)
	else:
		self.emit_signal("option_selected", option)
		
func on_cancel():
	# If there's nothing to go back to, we just re-focus the list.
	if options_stack.size() <= 1:
		options_list.on_grab_focus()
		return
	
	var current_options = options_stack.pop_back()
	var previous_options = options_stack.pop_back()
	
	self.set_options(previous_options)
		
	# if it's a sub option, we shouldn't emit it as a "cancel", since it's
	# only going through submenus
	if not current_options.get("is_sub_option", false):
		self.emit_signal("option_selected", null)

func hide_options():
	self.options.visible = false
	options_list.release_focus()

func hide_timeline():
	self.timeline_container.visible = false
	
func on_option_focused(option):
	# TODO: point at entities if targeting
	if "description" in option:
		self.options_info.visible = true
		self.options_info_label.text = option.description
	else:
		self.options_info.visible = false
		self.options_info_label.text = ''
	

func set_info_text(text):
	if text != null and text.length() > 0:
		self.info_label.text = text
		self.info_panel.visible = true
	else:
		self.info_panel.visible = false

func request_action_parameter(actor, actors: Array, argument_signature: Dictionary):
	match argument_signature["type"]:
		BattleAction.ActionArgument.TARGET:
			return await self.request_targets(actor, actors, argument_signature["targeting_type"])
		BattleAction.ActionArgument.ITEM:
			assert(false) #,"not yet implemented!")
			
func request_targets(actor, actors: Array, targeting_type: int):
	var target_options: Array
	match targeting_type: 
		BattleAction.TargetType.ONE_ENEMY:
			target_options = actor.get_enemies(actors)
		BattleAction.TargetType.ONE_ALLY:
			target_options = actor.get_allies(actors)
		BattleAction.TargetType.ALL_ENEMIES:
			self.all_enemies_option.targets = actor.get_enemies(actors)
			target_options = [self.all_enemies_option]
		BattleAction.TargetType.ALL_ALLIES:
			self.all_allies_option.targets = actor.get_allies(actors)
			target_options = [self.all_allies_option]
		BattleAction.TargetType.SELF:
			target_options = [actor]
			
	var new_options = {
		"options": target_options,
		"title": "Choose target(s)",
	}
	self.set_options(new_options)
	
	return self.option_selected
	
func update_preview(preview: Array):
	var r = "Turn Preview: "
	for b in range(preview.size()):
		r += preview[b].display_name 
		if b < (preview.size() - 1):
			r += " | "
	self.timeline.text = r
	self.timeline_container.visible = true
