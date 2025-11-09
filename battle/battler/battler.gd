# Base entity that represents a character or a monster in combat
# Every battler has an AI node so all characters can work as a monster
# or as a computer-controlled player ally
extends Node2D

class_name Battler

const MARIGOLD = Color("FF8E00")
const uniform_add: Material = preload("res://utils/material/uniform_add.tres")

@export var anim_path: NodePath
@export var stats: CharacterStats
@export var turn_order_icon: Texture2D
@export var rewards: BattleRewards
@export var toast_offset: Vector2 = Vector2(0,-32)

@onready var actions = $Actions
@onready var ai: BattlerAI = $AI
@onready var status_grid: Node = $StatusGrid
@onready var toast: Node2D = $Toast
@onready var hitbox: Area2D = $Hitbox
@onready var hitspots: Node = $Hitspots

var anim: Node
var status_effects = StatusEffectManager.new(self)
var pending_reaction = null

var health: int: set = set_health
var energy: int : set = set_energy

var is_alive: bool : 
	get:
		return health > 0

var level: int

var attack: float:
	get:
		var parent = self.get_parent()
		if parent is PartyMember:
				return (self.stats.attack + parent.attack_bonus) * self.status_effects.attack_modifier
		else:
			return self.stats.attack * self.status_effects.attack_modifier

var defense: float:
	get:
		var parent = self.get_parent()
		if parent is PartyMember:
			return clamp((self.stats.defense + parent.defense_bonus) * self.status_effects.defense_modifier, 0.0, 255.0)
		else:
			return clamp(self.stats.defense * self.status_effects.defense_modifier, 0.0, 255.0)
			

var magic_attack: float:
	get:
		var parent = self.get_parent()
		if parent is PartyMember:
			return (self.stats.magic_attack + parent.magic_attack_bonus) * self.status_effects.magic_attack_modifier
		else:
			return self.stats.magic_attack * self.status_effects.magic_attack_modifier


var magic_defense: float:
	get:
		var parent = self.get_parent()
		if parent is PartyMember:
			return clamp((self.stats.magic_defense + parent.magic_defense_bonus) * self.status_effects.magic_defense_modifier, 0.0, 255.0)
		else:
			return clamp(self.stats.magic_defense * self.status_effects.magic_defense_modifier, 0.0, 255.0)
			
		
var speed: float:
	get:
		var parent = self.get_parent()
		if parent is PartyMember:
			return (self.stats.speed + parent.speed_bonus) * self.status_effects.speed_modifier
		else:
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
	self.status_effects.added_or_removed.connect($StatusGrid.set_statuses)
	
func reset_stats():
	health = self.stats.max_health
	energy = self.stats.max_energy
	
func initialize(ui: BattleUI):
	self.ai.interface = ui

func free():
	self.status_effects.added_or_removed.disconnect($StatusGrid.set_statuses)
	self.status_effects._destroy()
	super.free()
	
func take_damage(damage: int):
	var parent = self.get_parent() 
	var max_health = self.stats.max_health if parent is not PartyMember else parent.max_health
	
	var prev_health = health
	health = clamp(health - damage, 0, max_health)
	
	if BattleService.in_battle and parent is PartyMember:
		BattleService.update_player_state()
	
	return prev_health - health

func set_health(value: int):
	var parent = self.get_parent()
	var max_health = self.stats.max_health if parent is not PartyMember else parent.max_health
	health = clamp(value, 0, max_health)
	if BattleService.in_battle and parent is PartyMember:
		BattleService.update_player_state()

func spend_energy(amount: int):
	var parent = self.get_parent() 
	var max_energy = self.stats.max_energy if parent is not PartyMember else parent.max_energy
	var prev_energy = energy
	energy = clamp(energy - amount, 0, max_energy)
	
	if BattleService.in_battle and parent is PartyMember:
		BattleService.update_player_state()
		
	return prev_energy - energy

func set_energy(value: int):
	var parent = self.get_parent() 
	var max_energy = self.stats.max_energy if parent is not PartyMember else parent.max_energy
	energy = clamp(value, 0, max_energy)
	if BattleService.in_battle and parent is PartyMember:
		BattleService.update_player_state()
	
func show_toast(text: String, color: Color=Color.WHITE):
	return self.toast.show_toast(text, color)

func get_vulnerability(hit: Hit) -> float:
	return self.status_effects.get_vulnerability(hit)

func take_hit(actor, hit: Hit, in_battle: bool = true):
	var parent = self.get_parent()
	var damage
	var energy_drain
	if not hit.animation_only:
		energy_drain = hit.energy_drain
		if hit.fixed_damage:
			damage = int(hit.base_damage)
		else:
			damage = hit.potential_damage * self.get_damage_modifier(hit) * self.get_vulnerability(hit)
			damage = int(ceil(damage + randf_range(1, damage * 0.2)))
			
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
		
		if hit.shake_duration > 0:
			hit_events.append(
				func():
					if hit.shake_time > 0:
						await tree.create_timer(hit.shake_time).timeout
					var shaker = FXService.shake(
						parent.anim, 
						hit.shake_duration, 
						hit.shake_amplitude, 
						hit.shake_time_scale,
						FXService.DecayMode.NONE
					)
					await shaker.shake_finished
			)
			
		if hit.hit_sound != null:
			hit_events.append(
				func():
					if hit.hit_sound_time > 0:
						await tree.create_timer(hit.hit_sound_time).timeout
					FXService.play_sfx_at(hit.hit_sound, self.global_position)
			)
			
		if not hit.animation_only:
			hit_events.append(
				func(): 
					if hit.toast_time > 0:
						await tree.create_timer(hit.toast_time).timeout
					self.toast.position = self.toast_offset
					hit.effective_damage = self.take_damage(damage)
					await self.toast.show_toast(str(damage))
					if energy_drain > 0:
						await tree.create_timer(0.2).timeout
						self.toast.position = self.toast_offset
						hit.effective_energy_drain = self.spend_energy(energy_drain)
						await self.toast.show_toast(str(energy_drain), MARIGOLD)
			)
				
		
		await DoAll.new(hit_events).execute()
		
		if self.health > 0:
			self.ai.check_reactions(parent, actor, hit, BattleService.get_actors())
		else:
			BattleService.notify_death(get_parent())
	else:
		hit.effective_damage = self.take_damage(damage)
		hit.effective_energy_drain = self.spend_energy(energy_drain)
	
func heal(amount: int, in_battle: bool = true):
	self.take_damage(-amount)
	if in_battle:
		self.toast.position = self.toast_offset
		return self.toast.show_toast(str(amount), Color.LIGHT_GREEN)
	
func recover_energy(amount: int, in_battle: bool = true):
	self.spend_energy(-amount)
	if in_battle:
		self.toast.position = self.toast_offset
		return self.toast.show_toast(str(amount), Color.STEEL_BLUE)

	
func get_damage_modifier(hit: Hit):
	var hit_defense: float
	if hit.type == Hit.Element.PHYSICAL:
		hit_defense = self.defense
	else:
		hit_defense = self.magic_defense
		
	return (1 - hit_defense/255.0)
	
func get_action_options() -> Array:
	var parent = self.get_parent()
	var options
	if parent is PartyMember:
		
		options = actions.get_children()
		
		# options.push_front(BattleService.common_action_options["lose"])
		# options.push_front(BattleService.common_action_options["win"])
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
	# FIXME should this be called for non-active party members as well?
	self.ai.interface = null
	self.status_grid.clear()
	self.status_effects.clear()
	self.hitbox.set_deferred("monitorable", false)

func pause_move_to():
	self.get_parent().pause_move_to()
	
func resume_move_to():
	self.get_parent().resume_move_to()

func skip_move_to():
	self.get_parent().skip_move_to()

func has_hitspot(hitspot_name: String):
	return hitspots.has_node(hitspot_name)

func get_hitspot(hitspot_name: String):
	var node = hitspots.get_node_or_null(hitspot_name)
	return node.global_position if node != null else self.global_position

func get_hitspot_for(attacker_position: Vector2) -> Vector2:
	var max_prod = -INF
	var min_distance = INF
	var best_spot = self.global_position
	for spot_name in self.hitspots.orientations:
		var orientation = VarsService.round_orientation_with_bias(global_position - attacker_position)
		var prod = orientation.dot(hitspots.orientations[spot_name])
		
		if prod < max_prod:
			continue
			
		var spot = hitspots.get_node(spot_name)
		var distance = attacker_position.distance_squared_to(spot.global_position)
		if distance < min_distance:
			max_prod = prod
			min_distance = distance
			best_spot = spot.global_position
	
	return best_spot
