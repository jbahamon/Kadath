extends VSplitContainer

onready var item_select_panel = $HBoxContainer/ItemSelectPanel
onready var party_list = $HBoxContainer/PartyList
onready var party_member_stats = $HBoxContainer/PartyMemberStats

export var icon: Texture

var inventory: Inventory

func initialize(party: Party):
	self.inventory = party.inventory
	party_list.initialize(party)
	item_select_panel.set_process_unhandled_input(false)
	party_member_stats.on_party_member_focused(party_list.get_first_party_member_item())
	
func show_item_panel(items: Array):
	item_select_panel.initialize(items)
	item_select_panel.rect_min_size = Vector2(party_list.rect_size[0], 0.0)
	item_select_panel.visible = true
	party_list.visible = false
	item_select_panel.set_process_unhandled_input(true)
	
func hide_item_panel():
	party_list.visible = true
	item_select_panel.visible = false
	item_select_panel.set_process_unhandled_input(false)

func receive_focus():
	var first_element = party_list.get_first_clickable_item()

	if first_element != null:
		first_element.grab_focus()
		first_element.grab_click_focus()
		return true
	else:
		return false

func relinquish_focus():
	return

func on_item_requested(cls, party_member: PartyMember):
	var items = self.inventory.get_equipment(cls, party_member.id)
	show_item_panel(items)

func on_item_selected(item: Equipment):
	hide_item_panel()
