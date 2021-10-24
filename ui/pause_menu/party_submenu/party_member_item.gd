extends MarginContainer

class_name PartyMemberItem

signal party_member_focused(party_member_item)
signal party_member_selected(party_member_item)

onready var button: Button = $Button
onready var icon = $MarginContainer/HBoxContainer/Icon
onready var character_name = $MarginContainer/HBoxContainer/Info/Name
onready var level = $MarginContainer/HBoxContainer/Info/Level
onready var hp = $MarginContainer/HBoxContainer/Info/HP
onready var ep = $MarginContainer/HBoxContainer/Info/EP

var party_member: PartyMember

func _ready():
	if party_member != null:
		self.update_party_member()


func initialize(party_member: PartyMember):
	self.party_member = party_member
	
	if self.is_inside_tree():
		self.update_party_member()

func set_only_focusable(only_focusable: bool):
	if not only_focusable:
		self.button.add_stylebox_override("pressed", self.button.get_stylebox("hover"))
		
func update_party_member():
	character_name.text = party_member.display_name
	icon.texture = party_member.icon
	var battler = party_member.battler
	level.text = 'Lv. %d' % battler.stats.level
	hp.text = '%d/%d' % [battler.stats.health, battler.stats.max_health]
	ep.text = '%d/%d' % [battler.stats.energy, battler.stats.max_energy]
	

func _on_Button_pressed():
	emit_signal("party_member_selected", self)


func _on_Button_focus_entered():
		emit_signal("party_member_focused", self)
