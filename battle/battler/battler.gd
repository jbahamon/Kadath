# Base entity that represents a character or a monster in combat
# Every battler has an AI node so all characters can work as a monster
# or as a computer-controlled player ally
extends Node

class_name Battler

signal died(battler)

export var stats: Resource
onready var drops := $Drops
onready var actions = $Actions
# onready var bars = $Bars
onready var skills = $Skills
onready var ai = $AI

var target_global_position: Vector2

var selected: bool = false setget set_selected
var selectable: bool = false setget set_selectable
var display_name: String

export var party_member = false
export var turn_order_icon: Texture


func _ready() -> void:
	var direction: Vector2 = Vector2(-1.0, 0.0) if party_member else Vector2(1.0, 0.0)
	selectable = true


func initialize():
	actions.initialize(skills.get_children())
	stats = stats.copy()
	stats.connect("health_depleted", self, "_on_health_depleted")


func is_able_to_play() -> bool:
	# Returns true if the battler can perform an action
	return stats.health > 0


func set_selected(value):
	selected = value


func set_selectable(value):
	selectable = value
	if not selectable:
		set_selected(false)


func take_damage(hit):
	stats.take_damage(hit)
	# prevent playing both stagger and death animation if health <= 0
	if stats.health > 0:
		self.play_anim('stagger')


func _on_health_depleted():
	selectable = false
	yield(self.play_anim('death'), "completed")
	emit_signal("died", self)

func play_anim(anim_name):
	self.get_parent().play_anim(anim_name)
		
func choose_action(battlers: Array):
	return self.ai.choose_action(battlers)

		
func choose_targets(battlers: Array):
	return self.ai.choose_targets(battlers)
