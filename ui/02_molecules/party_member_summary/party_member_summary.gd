extends MarginContainer

@onready var button: Button = $Button
@onready var character_name = $PanelContainer/Info/Name
@onready var hp_label = $PanelContainer/Info/HPContainer/HBoxContainer/HP
@onready var hp_bar = $PanelContainer/Info/HPContainer/ProgressBar
@onready var ep_label = $PanelContainer/Info/EPContainer/HBoxContainer/EP
@onready var ep_bar = $PanelContainer/Info/EPContainer/ProgressBar

var party_member

func _ready():
	self.update()
	
func update():
	
	if self.party_member != null:
		self.visible = true
		self.character_name.text = party_member.display_name
		var battler = party_member.battler

		hp_label.text = "%d" % battler.health
		hp_bar.max_value = battler.stats.max_health
		hp_bar.value = battler.health
		
		ep_label.text = "%d" % battler.energy
		ep_bar.max_value = battler.stats.max_energy
		ep_bar.value = battler.energy
	else:
		self.visible = false
	
func get_button():
	return button
