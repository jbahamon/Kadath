extends MarginContainer

export var clickable: bool = true

export var toggle: bool = true
export var normal_item: StyleBox
export var pressed_item: StyleBox
export var disabled_item: StyleBox
export var hover_item: StyleBox
export var focused_item: StyleBox


signal party_member_focused(party_member)
signal party_member_selected(party_member)

var PartyMemberSummary = preload("res://ui/02_molecules/party_member_summary/party_member_summary.tscn")

onready var vbox_container = $ScrollContainer/VBoxContainer
	
func initialize(party_members: Array):
	for child in vbox_container.get_children():
		child.disconnect("party_member_focused", self, "on_party_member_focused")
		child.disconnect("party_member_selected", self, "on_party_member_selected")
		vbox_container.remove_child(child)
		child.queue_free()
	
	for party_member in party_members:
		var item = PartyMemberSummary.instance()
		item.party_member = party_member
		vbox_container.add_child(item)
		item.connect("party_member_focused", self, "on_party_member_focused")
		item.connect("party_member_selected", self, "on_party_member_selected")
		item.set_only_focusable(clickable)
		item.button.focus_neighbour_left = item.button.get_path_to(item.button)
		item.button.focus_neighbour_right = item.button.get_path_to(item.button)
		
		if normal_item != null:
			item.button.add_stylebox_override("normal", normal_item)
		if pressed_item != null:
			item.button.add_stylebox_override("pressed", pressed_item)
		if disabled_item != null:
			item.button.add_stylebox_override("disabled", disabled_item)
		if hover_item != null:
			item.button.add_stylebox_override("hover", hover_item)
		if focused_item != null:
			item.button.add_stylebox_override("focus", focused_item)
			
		item.button.set_toggle_mode(self.toggle)
	
	var last_button = vbox_container.get_child(vbox_container.get_child_count() - 1).button
	last_button.focus_neighbour_bottom = last_button.get_path_to(last_button)
	

func on_party_member_focused(party_member: PartyMemberSummary):
	emit_signal("party_member_focused", party_member)
	
func on_party_member_selected(party_member_item: PartyMemberSummary):
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

func get_first_party_member_item() -> PartyMemberSummary:
	if vbox_container.get_child_count() > 0:
		return vbox_container.get_child(0)
	else:
		return null
