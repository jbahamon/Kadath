extends PanelContainer

@onready var summary: Label = $VBoxContainer/Summary

@onready var hp_data: Label = $VBoxContainer/HBoxContainer/HPData
@onready var weakness_label: Label
@onready var weakness_list: Label

@onready var resist_label: Label
@onready var resist_list: Label

@onready var absorb_label: Label
@onready var absorb_list: Label

func update(actor):
	summary.text = actor.enemy_info
	hp_data.text = "%s / %s" % [actor.battler.health, actor.battler.stats.max_health]
	# TODO show/hide other stats accordingly
