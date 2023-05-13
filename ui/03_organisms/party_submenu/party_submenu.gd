extends PanelContainer

@onready var item_list = $VSplitContainer/HBoxContainer/ItemList
@onready var party_list = $VSplitContainer/HBoxContainer/PartyList
@onready var party_member_stats = $VSplitContainer/HBoxContainer/PartyMemberStats

@export var icon: Texture2D

var inventory: Inventory

func initialize(party: Party):
	self.inventory = party.inventory
	var party_members = party.get_active_members()
	party_list.initialize(party_members)
	if party_members.size() > 0:
		party_member_stats.on_party_member_focused(party_members[0])
	
func on_grab_focus():
	var first_element = party_list.get_first_clickable_item()

	if first_element != null:
		first_element.grab_focus()
		first_element.grab_click_focus()
		return true
	else:
		return false

func on_release_focus():
	return

func on_item_requested(item_class, party_member: PartyMember):
	var items = self.inventory.get_equipment(item_class, party_member.id)
	self.item_list.custom_minimum_size = Vector2(party_list.size[0], 0.0)
	self.item_list.initialize(items)
	self.party_member_stats.set_process_unhandled_input(false)
	
	self.item_list.visible = true
	self.party_list.visible = false
	
	item_list.connect("element_focused", party_member_stats.on_item_focused)
	item_list.connect("element_selected", self.on_item_selected, CONNECT_ONE_SHOT)
	item_list.connect("element_selected", party_member_stats.on_item_selected, CONNECT_ONE_SHOT)
	
	item_list.connect("cancel", self.on_item_cancel, CONNECT_ONE_SHOT)
	item_list.connect("cancel", party_member_stats.on_item_cancel, CONNECT_ONE_SHOT)
		
	item_list.grab_focus()

func on_item_selected(_item: InventoryItem):
	self.item_list.visible = false
	self.party_list.visible = true
	self.party_member_stats.set_process_unhandled_input(true)
	
	item_list.disconnect("element_focused",Callable(party_member_stats,"on_item_focused"))
	
	item_list.disconnect("cancel", self.on_item_cancel)
	item_list.disconnect("cancel", party_member_stats.on_item_cancel)

	
func on_item_cancel():
	self.item_list.visible = false
	self.party_list.visible = true
	self.party_member_stats.set_process_unhandled_input(true)
	item_list.disconnect("element_focused",party_member_stats.on_item_focused)
	item_list.disconnect("element_selected", self.on_item_selected)
	item_list.disconnect("element_selected", party_member_stats.on_item_selected)
	

