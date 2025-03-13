extends PanelContainer

var PartyMemberListItem = preload("res://ui/02_molecules/party_member_list_item/party_member_list_item.tscn")

signal exit_submenu

const party_member_help = "Choose a party member to change their equipment."
const party_member_controls = "[{ui_up}]/[{ui_down}]: Select [{ui_cancel}]: Return [{ui_accept}]: Confirm"

const item_help = "Choose the item to equip."
const item_controls = "[{ui_up}]/[{ui_down}]: Select [{ui_cancel}]: Return [{ui_accept}]: Confirm"

@onready var item_list = $VBoxContainer/HBoxContainer/ItemList
@onready var party_container = $VBoxContainer/HBoxContainer/VBoxContainer
@onready var party_list = $VBoxContainer/HBoxContainer/VBoxContainer/PartyList
@onready var party_member_stats = $VBoxContainer/HBoxContainer/PartyMemberStats
@onready var party_details_separator = $VBoxContainer/HBoxContainer/VSeparator
@onready var details_items_separator = $VBoxContainer/HBoxContainer/VSeparator2
@export var icon: Texture2D
@export var help_text: String
@export var controls_text: String

var inventory: Inventory

func initialize():
	self.update_party_data()

func set_party_list_mode():
	# item_list.element_focused.disconnect(party_member_stats.on_item_focused)
	party_details_separator.visible = true
	details_items_separator.visible = false
	party_container.visible = true
	item_list.visible = false
	
func set_item_mode():
	# item_list.element_focused.connect(party_member_stats.on_item_focused)
	UIService.set_menu_help(item_help, item_controls)
	party_member_stats.set_process_unhandled_input(false)
	party_details_separator.visible = false
	details_items_separator.visible = true
	party_container.visible = false
	item_list.visible = true
	item_list.on_grab_focus()
	
func on_grab_focus():
	UIService.set_menu_help(party_member_help, party_member_controls)
	party_list.on_grab_focus()

func on_item_requested(item_class, party_member: PartyMember):
	var items = self.inventory.get_equipment(item_class, party_member.id)
	# TODO Armor can be removed but need to implement stat previews
	if item_class != Weapon and item_class != Armor:
		items.append(null)
	self.item_list.initialize(items)
	
	self.party_member_stats.set_process_unhandled_input(false)
	await self.set_item_mode()
	
	if items.size() > 0:
		await item_list.done
		UIService.play_interaction_sound()
	else:
		UIService.play_error_sound()
	await self.set_party_list_mode()
	
	self.party_member_stats.set_process_unhandled_input(true)
	
	self.party_member_stats.on_grab_focus()

func update_party_data():
	var party = EntitiesService.party
	self.inventory = party.inventory
	var party_members = party.get_active_members()
	party_list.initialize(party_members, {"class_or_scene": PartyMemberListItem})
	if party_members.size() > 0:
		party_member_stats.on_party_member_focused(party_members[0])
		
func _on_visibility_changed():
	if self.visible:
		self.set_party_list_mode()

func _on_party_list_cancel():
	self.exit_submenu.emit()
