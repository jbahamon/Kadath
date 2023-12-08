extends MarginContainer

@onready var button: Button = $Button
@onready var character_name = $PanelContainer/Info/Name
@onready var hp = $PanelContainer/Info/HP
@onready var ep = $PanelContainer/Info/EP
@onready var toast = $Control/Toast
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
	
func assign_element(element):
	self.party_member = element
	
func assign_null(args: Dictionary):
	character_name.text = args["name"]
	hp.text = args["hp"]
	ep.text = args["ep"]
	
func get_button():
	return button

func show_toast(text, color=Color.WHITE):
	self.toast.show_toast(text, color)
