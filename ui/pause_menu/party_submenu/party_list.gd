extends PanelContainer

signal party_member_focused(party_member)
signal party_member_selected(party_member)

export var clickable: bool = true
var PartyMemberItem = preload("res://ui/pause_menu/party_submenu/party_member_item.tscn")

onready var vbox_container = $ScrollContainer/VBoxContainer
	
func initialize(party: Party):
	for child in vbox_container.get_children():
		child.disconnect("party_member_focused", self, "on_party_member_focused")
		child.disconnect("party_member_selected", self, "on_party_member_selected")
		vbox_container.remove_child(child)
		child.queue_free()
	
	for party_member in party.get_active_members():
		var item = PartyMemberItem.instance()
		item.initialize(party_member)
		vbox_container.add_child(item)
		item.connect("party_member_focused", self, "on_party_member_focused")
		item.connect("party_member_selected", self, "on_party_member_selected")
		item.set_only_focusable(clickable)
		item.button.focus_neighbour_left = item.button.get_path_to(item.button)
		item.button.focus_neighbour_right = item.button.get_path_to(item.button)
	
	var last_button = vbox_container.get_child(vbox_container.get_child_count() - 1).button
	last_button.focus_neighbour_bottom = last_button.get_path_to(last_button)
	

func on_party_member_focused(party_member: PartyMemberItem):
	emit_signal("party_member_focused", party_member)
	
func on_party_member_selected(party_member_item: PartyMemberItem):
	party_member_item.button.pressed = true
	
	for child in vbox_container.get_children():
		if child.party_member != party_member_item.party_member:
			child.button.pressed = false
			
	emit_signal("party_member_selected", party_member_item)
	
func get_first_clickable_item():
	if vbox_container.get_child_count() > 0:
		return vbox_container.get_child(0).button
	else:
		return null

func get_first_party_member_item() -> PartyMemberItem:
	if vbox_container.get_child_count() > 0:
		return vbox_container.get_child(0)
	else:
		return null
