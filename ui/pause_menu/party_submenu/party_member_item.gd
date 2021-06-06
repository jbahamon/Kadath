extends CenterContainer

signal party_member_focused(party_member)
signal party_member_selected(party_member)

onready var icon = $HBoxContainer/Icon
onready var character_name = $HBoxContainer/Info/Name
onready var level = $HBoxContainer/Info/Level
onready var hp = $HBoxContainer/Info/HP
onready var ep = $HBoxContainer/Info/EP

var party_member: PartyMember

func _ready():
	if party_member != null:
		self.update_party_member()


func initialize(party_member: PartyMember):
	self.party_member = party_member
	
	if self.is_inside_tree():
		self.update_party_member()


func update_party_member():
	icon.texture = party_member.icon
	character_name.text = party_member.display_name
	level.text = 'Lv. %d' % party_member.stats.level
	hp.text = '%d/%d' % [party_member.stats.health, party_member.stats.max_health]
	ep.text = '%d/%d' % [party_member.stats.energy, party_member.stats.max_energy]
	

func _on_Button_pressed():
	emit_signal("party_member_selected", self.party_member)


func _on_Button_focus_entered():
		emit_signal("party_member_focused", self.party_member)
