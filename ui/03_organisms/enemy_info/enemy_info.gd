extends PanelContainer

@onready var hp_data: Label = $VBoxContainer/HBoxContainer/HPData
@onready var summary: Label = $VBoxContainer/Summary
@onready var matchups_section: Control = $VBoxContainer/GridContainer

@onready var weakness_label: Label
@onready var weakness_list: Label

@onready var resist_label: Label
@onready var resist_list: Label

@onready var absorb_label: Label
@onready var absorb_list: Label

func update(actor):
	self.reset()
	
	if ("enemy_id" not in actor or 
		actor.enemy_id == null or
		not VarsService.scanned_enemies.get(actor.enemy_id, false)
	):
		return
		
	if VarsService.scan_level > 0:
		self.show()
		hp_data.text = "%s / %s" % [actor.battler.health, actor.battler.stats.max_health]
		
	if VarsService.scan_level > 1:
		self.summary.show()
		self.summary.text = actor.enemy_info
	
	if VarsService.scan_level > 2:
		self.matchups_section.show()
		# TODO implement this at some point ;)
	
func reset():
	self.summary.hide()
	self.matchups_section.hide()
	self.hide()
