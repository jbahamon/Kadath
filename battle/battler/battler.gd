# Base entity that represents a character or a monster in combat
# Every battler has an AI node so all characters can work as a monster
# or as a computer-controlled player ally
extends Node

class_name Battler

export var anim_path: NodePath
export var stats: Resource # Should be Character Stats, tho
export var turn_order_icon: Texture
export var rewards: Resource

onready var actions = $Actions
onready var skills = $Skills
onready var ai = $AI

var anim: Node
var status_effects = StatusEffectManager.new()

func _ready():
	assert(anim_path)
	anim = get_node(anim_path)
	
func initialize(ui):
	ai.interface = ui

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
	var parent = self.get_parent()
	if parent is PartyMember:
		attack = (self.stats.attack * 0.7 + 
				  parent.get_physical_attack_bonus() * 0.3) 
	else:
		attack = self.stats.attack 
		
	return attack * self.status_effects.get_physical_attack_modifier()

func get_physical_defense() -> float:
	var defense
	var parent = self.get_parent()
	if parent is PartyMember:
		defense = self.stats.defense + parent.get_physical_armor()
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
		var result = self.die()
		if result is GDScriptFunctionState:
			yield(result, "completed")
		
func die():
	if self.rewards != null:
		BattleLoop.add_rewards(self.rewards)
		
	var parent = self.get_parent()
	BattleLoop.remove_actor(parent)
	
	if parent is PartyMember:
		self.status_effects.add(self, DownedStatus.new())
	else:
		var result = parent.die()
		if result is GDScriptFunctionState:
			yield(result, "completed")

func play_anim(anim_name: String):
	self.get_parent().play_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	self.get_parent().set_orientation(orientation)
	
func move_to(target_position: Vector2, speed: float):
	yield(self.get_parent().move_to(target_position), "completed")

func is_party_member():
	return get_parent() is PartyMember
