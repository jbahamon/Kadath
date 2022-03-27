extends MarginContainer

class_name PartyMemberSummary

onready var button: Button = $Button
onready var character_name = $MarginContainer/Info/Name
onready var level = $MarginContainer/Info/Level
onready var hp = $MarginContainer/Info/HP
onready var ep = $MarginContainer/Info/EP

var party_member

func _ready():
	if party_member != null:
		self.update_party_member()
	
func update_party_member():
	character_name.text = party_member.display_name
	var battler = party_member.battler
	level.text = "Lv. %d" % battler.stats.level
	hp.text = "%d/%d" % [battler.stats.health, battler.stats.max_health]
	ep.text = "%d/%d" % [battler.stats.energy, battler.stats.max_energy]

func get_button():
	return button
