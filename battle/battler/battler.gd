# Base entity that represents a character or a monster in combat
# Every battler has an AI node so all characters can work as a monster
# or as a computer-controlled player ally
extends Node

class_name Battler

export var is_party_member = false
export var display_name: String
export var anim_path: NodePath
export var icon: Texture
export var stats: Resource # Should be Character Stats, tho
export var turn_order_icon: Texture

onready var drops := $Drops
onready var actions = $Actions
onready var skills = $Skills
onready var ai = $AI

var anim: CharacterAnim
var status_effects = StatusEffectManager.new()

func _ready():
	assert(anim_path)
	anim = get_node(anim_path)
	
func initialize(ui):
	ai.interface = ui
	stats.reset()

func take_damage(hit: Hit):
	var damage = ceil(hit.base_damage * self.get_damage_modifier(hit) + rand_range(1, hit.base_damage*0.2))
	stats.take_damage(damage)
	
	if stats.health <= 0:
		BattleLoop.subscribe_to_event(
			self, 
			BattleLoop.Event.TURN_END, 
			BattleLoop.Subscription.FIRE_ONCE
		)

func get_damage_modifier(hit: Hit):
	var defense: float
	
	if hit.type == Hit.Element.PHYSICAL:
		defense = self.get_physical_defense()
	else:
		defense = self.get_elemental_defense()
		
	return (202 - min(defense, 200))/202
	
func get_physical_attack() -> float:
	var attack
	if self.is_party_member:
		var party_member: PartyMember = self.get_parent()
		attack = (self.stats.attack * 0.7 + 
				  party_member.get_physical_attack_bonus() * 0.3) 
	else:
		attack = self.stats.attack 
		
	return attack * self.status_effects.get_physical_attack_modifier()

func get_physical_defense() -> float:
	var defense
	if self.is_party_member:
		var party_member: PartyMember = get_parent()
		defense = self.stats.defense + party_member.get_physical_armor()
	else:
		defense = self.stats.defense
		
	return defense * status_effects.get_physical_defense_modifier()
		
func get_elemental_defense() -> float:
	return 1.0

func get_speed() -> float:
	return self.stats.speed * self.status_effects.get_speed_modifier()

func get_actions() -> Array:
	return actions.get_children()

func is_alive() -> bool:
	return self.stats.is_alive

func on_turn_end():
	if stats.health <= 0:
		self.die()
		
func die():
	BattleLoop.remove_battler(self)
	
	if self.is_party_member:
		self.status_effects.add(self, DownedStatus.new())
	else:
		self.queue_free()
