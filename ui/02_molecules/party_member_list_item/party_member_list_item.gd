extends MarginContainer

@onready var button: Button = $Button
@onready var character_name = $PanelContainer/MarginContainer/Info/Name
@onready var hp_label = $PanelContainer/MarginContainer/Info/HPContainer/HBoxContainer/HP
@onready var hp_bar = $PanelContainer/MarginContainer/Info/HPContainer/ProgressBar
@onready var ep_label = $PanelContainer/MarginContainer/Info/EPContainer/HBoxContainer/EP
@onready var ep_bar = $PanelContainer/MarginContainer/Info/EPContainer/ProgressBar
@onready var toast = $Control/Toast
var party_member: PartyMember

var health:
	get:
		return self.party_member.health
		
func _ready():
	self.update()
	
func update():
	if self.party_member != null:
		self.visible = true
		character_name.text = party_member.display_name
		var battler = party_member.battler

		hp_label.text = "%d/%d" % [battler.health, battler.stats.max_health]
		hp_bar.max_value = battler.stats.max_health
		hp_bar.value = battler.health
		
		ep_label.text = "%d/%d" % [battler.energy, battler.stats.max_energy]
		ep_bar.max_value = battler.stats.max_energy
		ep_bar.value = battler.energy
		
	else:
		self.visible = false
	
func assign_element(element):
	self.party_member = element
	
func assign_null(args: Dictionary):
	character_name.text = args["name"]
	hp_label.text = args["hp"]
	ep_label.text = args["ep"]
	
func get_button():
	return button
	
func heal(amount: int):
	self.party_member.heal(amount, false)
	self.update()
	
func recover_energy(amount: int):
	self.party_member.recover_energy(amount, false)
	self.update()
	
func show_toast(text: String, color: Color = Color.WHITE):
	return self.toast.show_toast(text, color)
