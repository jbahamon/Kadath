extends PanelContainer

signal party_member_focused(party_member)
signal party_member_selected(party_member)

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
		item.connect('party_member_focused', self, "on_party_member_focused")
		item.connect('party_member_selected', self, "on_party_member_selected")
		vbox_container.add_child(item)
	
	
func on_party_member_focused(party_member: PartyMember):
	print("huh")
	emit_signal("party_member_focused", party_member)
	
	
func on_party_member_selected(party_member: PartyMember):
	emit_signal("party_member_selected", party_member)

	
func get_first_item():
	if vbox_container.get_child_count() > 0:
		return vbox_container.get_child(0).get_child(0)
	else:
		return null
