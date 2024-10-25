extends MarginContainer

@onready var button: Button = $Button
@onready var character_name = $PanelContainer/Info/Name
@onready var hp = $PanelContainer/Info/HP
@onready var ep = $PanelContainer/Info/EP

var party_member

func _ready():
	self.update()
	
func update():
	
	if self.party_member != null:
		self.visible = true
		self.character_name.text = party_member.display_name
		var battler = party_member.battler

		hp.text = "%d/%d" % [battler.health, battler.stats.max_health]
		ep.text = "%d/%d" % [battler.energy, battler.stats.max_energy]
	else:
		self.visible = false
	

func get_button():
	return button
	
