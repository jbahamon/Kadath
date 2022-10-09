extends MarginContainer

var BattleAction = preload("res://battle/actions/battle_action.gd")
var MultiTargetOption = load("res://ui/04_templates/battle_ui/multi_target_option.gd")

class_name BattleUI

onready var party_list = $VBoxContainer/HBoxContainer/PartyList
onready var options = $VBoxContainer/HBoxContainer/Options
onready var options_title: Label = $VBoxContainer/HBoxContainer/Options/OptionsTitle/Label
onready var options_list = $VBoxContainer/HBoxContainer/Options/OptionsList/SelectList
onready var info_panel = $VBoxContainer/InfoPanel
onready var info_label = $VBoxContainer/InfoPanel/InfoLabel

signal option_selected(option)
signal prompt_closed
signal cancel

var options_stack: Array = []
var waiting_for_prompt: bool = false
var all_allies_option = MultiTargetOption.new()
var all_enemies_option = MultiTargetOption.new()

func _init():
	self.all_allies_option.name = "All allies"
	self.all_allies_option.targets = []
	self.all_enemies_option.name = "All enemies"
	self.all_enemies_option.targets = []

func prompt(text: String):
	self.waiting_for_prompt = true
	self.set_info_text(text)
	yield(self, "prompt_closed")
	self.waiting_for_prompt = false

func _unhandled_input(event):
	if waiting_for_prompt and (
		event.is_action_pressed("ui_accept") or 
		event.is_action_pressed("ui_cancel")
	):
		self.set_info_text(null)
		emit_signal("prompt_closed")
		

func initialize(party_members: Array):
	party_list.initialize(party_members)
	# TODO set top margin 
	self.hide_options()
	self.set_info_text(null)
	
func request_action(actions: Array):
	# TODO: highlight the actor, disable all others, align thing
	self.options_stack = [{
		"options": actions,
		"title": "Choose an action",
		"include_cancel_button": false
		}
	]
	
	self.set_options(options_stack[0])

func request_argument(actor, actors: Array, argument_definition: Dictionary):
	match argument_definition["type"]:
		BattleAction.ActionArgument.TARGET:
			self.request_targets(actor, actors, argument_definition["targeting_type"])
		BattleAction.ActionArgument.ITEM:
			assert(false, "not yet implemented!")
			
func request_targets(actor, actors: Array, targeting_type: int):
	self.options_stack = []
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
	self.set_options({
		"options": target_options,
		"title": "Choose target(s)",
		"include_cancel_button": true
	})

func hide_options():
	self.options.visible = false
	options_list.release_focus()
	
func on_option_focused(option):
	self.set_info_text(option.get("description"))
	# TODO: point at entities if targeting

func set_info_text(text):
	if text != null and text.length() > 0:
		self.info_label.text = text
		self.info_panel.visible = true
	else:
		self.info_panel.visible = false

func on_option_selected(option):
	if option is BattleActionType:
		self.on_action_type_selected(option)
	else:
		self.hide_options()
		self.emit_signal("option_selected", option)

func on_action_type_selected(action_type: BattleActionType):
	var new_options = {
		"options": action_type.get_actions(),
		"title": action_type.prompt,
		"include_cancel_button": true
	}
	
	options_stack.push_back(new_options)
	self.set_options(new_options)

func set_options(options):
	self.options.visible = true
	options_title.text = options["title"]
	options_list.include_cancel_button = options["include_cancel_button"]
	options_list.initialize(options["options"])
	options_list.grab_focus()
	
func on_cancel():
	var previous_options = options_stack.pop_back()
	if previous_options != null:
		self.set_options(previous_options)
	self.emit_signal("cancel")
