# Base entity that represents a character or a monster in combat
# Every battler has an AI node so all characters can work as a monster
# or as a computer-controlled player ally
extends Node2D

class_name Battler

const uniform_add: Material = preload("res://utils/material/uniform_add.tres")

@export var anim_path: NodePath
@export var stats: CharacterStats
@export var turn_order_icon: Texture2D
@export var rewards: BattleRewards
@export var toast_offset: Vector2 = Vector2(0,-32)

@onready var actions = $Actions
@onready var skills = $Skills
@onready var ai: BattlerAI = $AI
@onready var toast: Node2D = $Toast
@onready var hitbox: Area2D = $Hitbox
@onready var hitspots: Node = $Hitspots

var anim: Node
var status_effects = StatusEffectManager.new(self)
var pending_reaction = null

var health: int
var energy: int : set = set_energy

var is_alive: bool : 
	get:
		return health > 0

var level: int

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
	self.reset_stats()
	
func reset_stats():
	health = self.stats.max_health
	energy = self.stats.max_energy
	
func initialize(ui: BattleUI):
	self.ai.interface = ui

func free():
	self.status_effects._destroy()
	super.free()
	
func take_damage(damage: int):
	var prev_health = health
	health = clamp(health - damage, 0, self.stats.max_health)
	return prev_health - health

func spend_energy(amount: int):
	energy = clamp(energy - amount, 0, self.stats.max_energy)

func set_energy(value: int):
	energy = clamp(value, 0, self.stats.max_energy)
	
func show_toast(text: String, color: Color=Color.WHITE):
	await self.toast.show_toast(text, color)

func take_hit(hit: Hit, in_battle: bool = true):
	var damage
	if hit.fixed_damage:
		damage = hit.base_damage 
	else:
		damage = hit.base_damage * self.get_damage_modifier(hit) 
		damage = ceil(damage + randf_range(1, damage * 0.2))
		
	var actual_damage = self.take_damage(damage)
	var parent = self.get_parent()
		
	if in_battle:
		var hit_events = []
		var tree = self.get_tree()

		if hit.anim_duration > 0 and self.has_anim("hit"):
			var idle_anim = "battle_idle" if self.has_anim("battle_idle") else "idle"
				
			hit_events.append(
				func (): 
					if hit.anim_time > 0:
						await tree.create_timer(hit.anim_time).timeout
					self.play_anim("hit")
					await tree.create_timer(hit.anim_duration).timeout
					self.play_anim(idle_anim)
			)
		
		if hit.palfx_duration > 0:
			var prev_material = parent.material
			hit_events.append(
				func ():
					# Small correction since anim seems to change before the material :/
					await tree.create_timer(hit.palfx_time + 0.05).timeout
					parent.material = hit.palfx_material
					await tree.create_timer(hit.palfx_duration).timeout
					parent.material = prev_material
			)

		hit_events.append(
			func(): 
				await tree.create_timer(hit.toast_time).timeout
				self.toast.position = self.toast_offset
				self.toast.show_toast(str(damage))
				await tree.create_timer(0.7).timeout # Toast duration
		)
		
		await DoAll.new(hit_events).execute()
		
		if self.health > 0:
			self.ai.check_reactions(parent, hit, BattleService.get_actors())

	hit.effective_damage = actual_damage
	
func heal(amount: int, in_battle: bool = true):
	if in_battle:
		self.toast.position = self.toast_offset
		await self.toast.show_toast(str(amount), Color.LIGHT_GREEN)
	
	self.take_damage(-amount)
	
func recover_energy(amount: int, in_battle: bool = true):
	if in_battle:
		self.toast.position = self.toast_offset
		await self.toast.show_toast(str(amount), Color.STEEL_BLUE)
	
	self.spend_energy(-amount)
	
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
		
		# options.push_front(BattleService.common_action_options["lose"])
		# options.push_front(BattleService.common_action_options["win"])
		options.push_front(BattleService.common_action_options["attack"])
		options.push_back(BattleService.common_action_options["item"])
		options.push_back(BattleService.common_action_options["defend"])
		
		
		if BattleService.current_battle_parameters.get("escapable", true):
			options.append(BattleService.common_action_options["escape"])
		
	else:
		options = actions.get_children()
		
	return options

func play_anim(anim_name: String):
	self.get_parent().play_anim(anim_name)

func has_anim(anim_name: String) -> bool:
	return self.get_parent().has_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	self.get_parent().set_orientation(orientation)
	
func move_to(target_position: Array, move_speed: float):
	await self.get_parent().move_to(target_position, move_speed)

func is_party_member():
	return get_parent() is PartyMember

func on_battle_start():
	self.hitbox.set_deferred("monitorable", true)
	
func on_battle_end():
	self.status_effects.clear()
	self.hitbox.set_deferred("monitorable", false)

func pause_move_to():
	self.get_parent().pause_move_to()
	
func resume_move_to():
	self.get_parent().resume_move_to()

func skip_move_to():
	self.get_parent().skip_move_to()

func get_hitspot(hitspot_name: String):
	var node = hitspots.get_node_or_null(hitspot_name)
	return node.global_position if node != null else self.global_position
	
func get_nearest_hitspot_to(target_position: Vector2):
	var min_distance = INF
	var nearest_spot = self.global_position
	for spot in self.hitspots.get_children():
		var distance = target_position.distance_squared_to(spot.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_spot = spot.global_position
			
	return nearest_spot
