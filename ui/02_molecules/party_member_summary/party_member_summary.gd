extends MarginContainer

class_name PartyMemberSummary

@onready var button: Button = $Button
@onready var character_name = $MarginContainer/Info/Name
@onready var hp = $MarginContainer/Info/HP
@onready var ep = $MarginContainer/Info/EP

var disabled = false
var party_member

func _ready():
	self.update()
	
func update():
	
	if self.party_member != null:
		self.visible = true
		character_name.text = party_member.display_name
		var battler = party_member.battler

		hp.text = "%d/%d" % [battler.stats.health, battler.stats.max_health]
		ep.text = "%d/%d" % [battler.stats.energy, battler.stats.max_energy]
	else:
		self.visible = false
	

func get_button():
	return button
	
