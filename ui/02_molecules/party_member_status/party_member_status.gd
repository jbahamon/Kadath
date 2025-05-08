extends Control

@onready var icon: TextureRect = $Icon
@onready var hp_label = $HPLabel
@onready var hp_bar = $HPBar
@onready var hp_bar_bg = $HPBarBG
@onready var sp_label = $SPLabel
@onready var sp_bar = $SPBar
@onready var sp_bar_bg = $SPBarBG

var flash_threshold = 1.0/3.0
var party_member

func _ready():
	pass
	
func update():
	
	if self.party_member != null:
		self.visible = true
		var battler = party_member.battler

		hp_label.text = "%d" % battler.health
		hp_bar.max_value = battler.stats.max_health
		hp_bar.value = battler.health
		hp_bar_bg.visible = party_member.is_alive and float(battler.health)/float(battler.stats.max_health) < flash_threshold

		sp_label.text = "%d" % battler.energy
		sp_bar.max_value = battler.stats.max_energy
		sp_bar.value = battler.energy
		sp_bar_bg.visible = party_member.is_alive and float(battler.energy)/float(battler.stats.max_energy) < flash_threshold
		
		icon.texture = self.party_member.icon
	else:
		self.visible = false
