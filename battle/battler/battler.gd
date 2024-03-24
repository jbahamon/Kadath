# Base entity that represents a character or a monster in combat
# Every battler has an AI node so all characters can work as a monster
# or as a computer-controlled player ally
extends Node2D

class_name Battler
signal died

@export var anim_path: NodePath
@export var stats: CharacterStats
@export var turn_order_icon: Texture2D
@export var rewards: BattleRewards
@export var toast_offset: Vector2 = Vector2(0,-32)

@onready var actions = $Actions
@onready var skills = $Skills
@onready var ai: BattlerAI = $AI
@onready var toast: Node2D = $Toast

var anim: Node
var status_effects = StatusEffectManager.new(self)

var is_alive: bool:
	get:
		return self.stats.is_alive

var physical_attack: float:
	get:
		var attack
		var parent = self.get_parent()
		if parent is PartyMember:
			attack = (self.stats.attack * 0.7 + 
				parent.physical_attack_bonus * 0.3) 
		else:
			attack = self.stats.attack 
			
		return attack * self.status_effects.physical_attack_modifier

var physical_defense: float:
	get:
		var defense
		var parent = self.get_parent()
		if parent is PartyMember:
			defense = self.stats.defense + parent.physical_armor
		else:
			defense = self.stats.defense
			
		return defense * status_effects.physical_defense_modifier
		
var elemental_defense: float:
	get:
		return 1.0

var speed: float:
	get:
		return self.stats.speed * self.status_effects.speed_modifier

var display_name: String:
	get:
		return self.get_parent().display_name
	set(_value):
		pass

func _ready():
	assert(self.anim_path)
	self.anim = get_node(self.anim_path)
	self.toast.position = self.toast_offset
	
func free():
	self.status_effects._destroy()
	super.free()
	
func show_toast(text: String, color: Color=Color.WHITE):
	await self.toast.show_toast(text, color)
	
func initialize(ui: BattleUI):
	self.ai.interface = ui

func take_hit(hit: Hit, in_battle: bool = true):
	var damage = ceil(hit.base_damage * self.get_damage_modifier(hit) + randf_range(1, hit.base_damage*0.2))
	
	if in_battle:
		await self.toast.show_toast(str(damage))
		
	self.stats.take_damage(damage)
	
	if in_battle and self.stats.health <= 0:
		emit_signal("died", self.get_parent())
	return damage
	
func heal(amount: int):
	self.stats.heal(amount)
	
func recover_energy(amount: int):
	self.stats.recover_energy(amount)
	
func get_damage_modifier(hit: Hit):
	var defense: float
	
	if hit.type == Hit.Element.PHYSICAL:
		defense = self.physical_defense
	else:
		defense = self.elemental_defense
		
	return (202 - min(defense, 200))/202
	
func get_action_options() -> Array:
	var parent = self.get_parent()
	var options
	if parent is PartyMember:
		
		options = actions.get_children()
		
		options.push_front(BattleService.common_action_options["lose"])
		options.push_front(BattleService.common_action_options["win"])
		options.push_front(BattleService.common_action_options["defend"])
		options.push_front(BattleService.common_action_options["attack"])
		options.push_back(BattleService.common_action_options["item"])
		
		
		if BattleService.current_battle_parameters.get("escapable", false):
			options.append(BattleService.common_action_options["escape"])
		
	else:
		options = actions.get_children()
		options.append(BattleService.common_action_options["attack"])
		
	return options


func play_anim(anim_name: String):
	self.get_parent().play_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	self.get_parent().set_orientation(orientation)
	
func move_to(target_position: Array, move_speed: float):
	await self.get_parent().move_to(target_position, move_speed)

func is_party_member():
	return get_parent() is PartyMember

func on_battle_end():
	self.status_effects.clear()
