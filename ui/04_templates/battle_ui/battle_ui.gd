extends MarginContainer

class_name BattleUI

var ItemEntry = preload("res://ui/02_molecules/item_list_item/item_list_item.tscn")

@onready var party_status = $VBoxContainer/PartyStatusContainer/PartyStatus
@onready var options = $VBoxContainer/OptionsContainer

@onready var options_title_container = $VBoxContainer/TitleContainer
@onready var options_title: Label = $VBoxContainer/TitleContainer/OptionsTitle/Label
@onready var options_list = $VBoxContainer/OptionsContainer/OptionsList

@onready var skill_costs = $VBoxContainer/OptionsContainer/SkillCosts
@onready var enemy_info = $VBoxContainer/OptionsContainer/EnemyInfo
@onready var timeline = $VBoxContainer/Timeline

@onready var info_panel = $VBoxContainer/InfoPanel
@onready var info_label = $VBoxContainer/InfoPanel/HBoxContainer/InfoLabel
@onready var advance_label = $VBoxContainer/InfoPanel/HBoxContainer/AdvanceIndicator
@onready var advance_icon = $VBoxContainer/InfoPanel/HBoxContainer/AdvanceIcon

signal option_selected(option)
signal prompt_closed

var current_actor
var options_stack: Array = []
var waiting_for_prompt: bool = false

func initialize(party_members: Array):
	party_status.initialize(party_members)
	self.reset_options_stack()
	self.set_info_text(null)
	
func start():
	self.options_title_container.visible = false
	self.options.visible = false
	self.options_list.set_process_unhandled_input(false)
	self.show()
		
func prompt(text: String):
	var advance_keycode = InputMap.action_get_events(&"ui_accept")[0].keycode
	var cancel_keycode = InputMap.action_get_events(&"ui_cancel")[0].keycode
	var advance_indicator = "[pulse freq=1.0 color=#ffffff40 ease=-2.0][%s]/[%s][/pulse]" % [ 
		OS.get_keycode_string(advance_keycode),
		OS.get_keycode_string(cancel_keycode) 
	]
		
	self.set_info_text(text, advance_indicator)
	
	# We wait for a single frame to avoid using current inputs
	await get_tree().process_frame
	self.waiting_for_prompt = true
	await self.prompt_closed
	self.waiting_for_prompt = false

func _unhandled_input(event):
	if waiting_for_prompt and (
		event.is_action_pressed(&"ui_accept") or 
		event.is_action_pressed(&"ui_cancel")
	):
		self.set_info_text(null)
		self.prompt_closed.emit()
		self.get_viewport().set_input_as_handled()

func reset_options_stack():
	self.options_stack = []

func set_options(new_options):
	self.options_stack.push_back(new_options)
	self.options_title_container.visible = true
	self.options.visible = true
	options_title.text = new_options["title"]
	options_list.initialize(new_options["options"], new_options.get("list_options", {}))
	options_list.on_grab_focus()
	options_list.set_process_unhandled_input(true)
	
func on_option_selected(option):
	self.timeline.highlight({})
	if option is CompositeBattleOption:
		var new_options = {
			"from": option,
			"is_sub_option": true,
			"title": option.get_prompt(),
			"options": option.get_options(),
			"list_options": {
				"disable_func": func(opt): return opt.is_disabled(self.current_actor)
			}
		}
		
		self.set_options(new_options)
	else:
		self.option_selected.emit(option)
		
func on_cancel():
	# If there's nothing to go back to, we just re-focus the list.
	if options_stack.size() <= 1:
		options_list.on_grab_focus()
		return
	
	var current_options = options_stack.pop_back()
	var previous_options = options_stack.pop_back()

	# if the previous option is an action, we need to re-push it. 
	# Otherwise, the action itself will do it
	
	var origin = previous_options.get("from")
	if not origin is BattleAction:
		self.set_options(previous_options)
		
	# if it's a sub option, we shouldn't emit it as a "cancel", since it's
	# only going through submenus
	if not current_options.get("is_sub_option", false):
		self.option_selected.emit(null)

func hide_options():
	self.options_title_container.visible = false
	self.options.visible = false
	options_list.release_focus()
	options_list.set_process_unhandled_input(false)

func hide_timeline():
	self.timeline.modulate = Color.TRANSPARENT
	
func on_option_focused(option):
	if "description" in option:
		self.set_info_text(option.description)
	else:
		self.set_info_text(null)
		
	var parent_option = options_stack[options_stack.size() - 1].get("from")
	if parent_option != null:
		parent_option.highlight_option(current_actor, option)
	
	skill_costs.hide()
	enemy_info.hide()
	
	if option is PartyMember or option is BaseNPC:
		self.timeline.highlight({option.display_name: true})
		
		if option is BaseNPC:
			enemy_info.show()
			enemy_info.update(option)
			
	elif option is Array and option.size() > 0 and (option[0] is PartyMember or option[0] is BaseNPC):
		var highlights = {}
		for actor in options:
			highlights[actor.display_name] = true
		self.timeline.highlight(highlights)
	elif option is BattleAction:
		self.timeline.highlight({})
		if option.energy_cost > 0:
			skill_costs.update_costs([[current_actor, option.energy_cost]])
	else:
		self.timeline.highlight({})

func set_info_text(text, advance_text=null):
	if text != null and text.length() > 0:
		self.advance_label.text = "" if advance_text == null else advance_text
		
		if advance_text != null:
			self.advance_icon.show()
		else:
			self.advance_icon.hide()
			
		self.info_label.text = text
		self.info_panel.modulate = Color.WHITE
	else:
		self.info_panel.modulate = Color.TRANSPARENT

func request_action_parameter(action, actor, actors: Array, argument_signature: Dictionary):
	match argument_signature["type"]:
		BattleAction.ActionArgument.TARGET:
			return await self.request_targets(argument_signature["targeting_type"], action, actor, actors, argument_signature.get("prompt"))
		BattleAction.ActionArgument.ITEM:
			return await self.request_item(action, actor, actors, argument_signature["prompt"])

func request_item(action, actor, _actors: Array, _request_prompt: String):
	assert(actor is PartyMember)
	var inventory: Inventory = EntitiesService.party.inventory
	var item_options = inventory.get_batle_items_amounts()
	var new_options = {
		"from": action,
		"options": item_options,
		"title": "Choose an item",
		"list_options": {"class_or_scene": ItemEntry}
	}
	self.set_options(new_options)
	
	var item_and_amount = await self.option_selected
	
	if item_and_amount == null:
		return null
	else:
		return ItemService.id_to_item(item_and_amount[0])

func request_targets(targeting_type, action, actor, actors: Array, request_prompt: String):
	var target_options: Array = action.get_targets(targeting_type, actor, actors)
	
	var new_options = {
		"from": action,
		"options": target_options,
		"title": request_prompt,
	}
	self.set_options(new_options)
	
	return self.option_selected

func update_preview(actors: Array):
	self.timeline.update_preview(actors)
	self.timeline.modulate = Color.WHITE
	
func update_player_state():
	party_status.update()
