# Represents a playable character to add in the player's party
# Holds the data and nodes for the character's battler, anim,
# and the character's stats to save the game
extends Node2D
class_name PartyMember

var PartyMemberSummary = preload("res://ui/02_molecules/party_member_summary/party_member_summary.tscn")

signal move_to_done

enum Id {
	ALEX = 1 << 0,
	VOLKI = 1 << 1,
	GRUSKA = 1 << 2,
	SYLVIE = 1 << 3,
	PICKMAN = 1 << 4,
	KURANES = 1 << 5,
	ZKAUBA = 1 << 6,
	CARTER = 1 << 7,
}

const PARTY_IN_BATTLE_ID = {
	Id.ALEX: "Alex",
	Id.VOLKI: "Volki",
	Id.GRUSKA: "Gruska",
	Id.SYLVIE: "Sylvie",
	Id.PICKMAN: "Pickman",
	Id.KURANES: "Kuranes",
	Id.ZKAUBA: "Zkauba",
	Id.CARTER: "Carter",	
}

@onready var SAVE_KEY: String = "party_member_" + PARTY_IN_BATTLE_ID[self.id]
@onready var anim = $Anim
@onready var battler: Battler = $Battler

@export_flags ("Alex", "Volki", "Gruska", "Sylvie", "Pickman", "Kuranes", "Zkauba", "Carter") var id: int = Id.ALEX
@export var display_name: String
@export var growth: Resource
@export var unlocked = false
@export var experience: int : set = _set_experience
@export var icon: Texture2D
@export var menu_texture: Texture2D
@export var unique_command: NodePath

@export var starting_weapon_id: String
@export var starting_armor_id: String
@export var starting_accessory_id: String

var equipped_weapon: Weapon
var equipped_armor: Armor
var equipped_accessory: Accessory


var current_orientation = Vector2.DOWN
var velocity: Vector2 = Vector2.ZERO

var max_health:
	get:
		return self.battler.stats.max_health

var max_energy:
	get:
		return self.battler.stats.max_energy

var health:
	get:
		return self.battler.health

var energy:
	get:
		return self.battler.energy

var level: int:
	get:
		if battler == null:
			return -1
		
		return battler.stats.level
	
var physical_attack_bonus: float:
	get:
		return float(equipped_weapon.attack if equipped_weapon != null else 0)
	
var physical_armor: float:
	get:
		return float(
			(equipped_armor.defense if equipped_armor != null else 0)
		)
	
var magic_armor: float:
	get:
		return float(
			(equipped_armor.magic_defense if equipped_armor != null else 0)
		)

var is_alive: bool :
	get:
		return self.battler.is_alive

var in_battle_id: String:
	get:
		return PARTY_IN_BATTLE_ID[self.id]

var move_timer

func _ready():
	assert(growth)
	self.set_physics_process(false)
	battler.stats = growth.create_stats(experience)
	battler.reset_stats()
	
	if self.starting_weapon_id != null:
		self.equipped_weapon = ItemService.id_to_item(self.starting_weapon_id)
	
	if self.starting_armor_id != null:
		self.equipped_armor = ItemService.id_to_item(self.starting_armor_id)
		
	if self.starting_accessory_id != null:
		self.equipped_accessory = ItemService.id_to_item(self.starting_accessory_id)

func _physics_process(delta):
	self.position += velocity * delta
	
func update_stats():
	if battler == null:
		return
	# Update this character's stats to match stat changes
	# that occurred during combat or through menu actions
	var before_level = battler.stats.level
	var after_level = growth.get_level(experience)
	if before_level != after_level:
		battler.stats = growth.create_stats(experience)
		battler.reset_stats()

func _set_experience(value: int):
	experience = max(0, value)
	update_stats()

func save(save_data: SaveData):
	var skills = {}
	
	for skill in self.battler.actions.get_node("Skills").get_children():
		skills[skill.get_name()] = skill.unlocked
	
	save_data.data[SAVE_KEY] = {
		"display_name": display_name,
		"unlocked": unlocked,
		"equipped_weapon": equipped_weapon.id if equipped_weapon != null else null,
		"equipped_armor": equipped_armor.id if equipped_armor != null else null,
		"equipped_accessory": equipped_accessory.id if equipped_accessory != null else null,
		"experience": experience,
		"health": battler.health,
		"energy": battler.energy,
		"skills": skills,
	}

func load_game_data(save_data: SaveData):
	var data: Dictionary = save_data.data[SAVE_KEY]
	display_name = data["display_name"]
	unlocked = data["unlocked"]
	
	equipped_weapon = ItemService.id_to_item(data["equipped_weapon"]) if data["equipped_weapon"] != null else null
	equipped_armor = ItemService.id_to_item(data["equipped_armor"]) if data["equipped_armor"] != null else null
	equipped_accessory = ItemService.id_to_item(data["equipped_accessory"]) if data["equipped_accessory"] != null else null
	
	experience = data["experience"]
	battler.stats = growth.create_stats(experience)
	
	battler.health = data["health"]
	battler.energy = data["energy"]
	
	for skill in self.battler.skills.get_children():
		skill.unlocked = data["skills"][skill.get_name()]

func unlock_skill(skill_id: String):
	self.find_child("Battler/Actions/Skill/%s".format(skill_id)).unlock()

func instance_ui_control():
	var control = PartyMemberSummary.instantiate()
	control.party_member = self
	return control

# Methods for battles	
	
func get_allies(actors: Array):
	return actors.filter(func(actor): return actor is PartyMember)
	
func get_enemies(actors: Array):
	return actors.filter(func(actor): return not actor is PartyMember)
	
func take_hit(actor, hit: Hit, in_battle: bool = true):
	return await self.battler.take_hit(actor, hit, in_battle)

func heal(amount: int, in_battle: bool = true):
	await self.battler.heal(amount, in_battle)
	
func recover_energy(amount: int, in_battle: bool = true):
	await self.battler.recover_energy(amount, in_battle)
	
func show_toast(text: String, color: Color=Color.WHITE):
	await self.battler.show_toast(text, color)	

func get_current_anim():
	return self.anim.get_current_anim()
	
# Animatable interface

func play_anim(anim_name: String):
	self.anim.play_anim(anim_name)

func has_anim(anim_name: String) -> bool:
	return self.anim.has_anim(anim_name)

func set_orientation(new_orientation: Vector2):
	self.current_orientation = new_orientation
	self.anim.set_orientation(new_orientation)

func move_to(target: Array, speed):
	assert(speed > 0)
	var target_position = Vector2(
		target[0] if target[0] != null else self.global_position.x,
		target[1] if target[1] != null else self.global_position.y
	)
	var was_processing_physics = self.is_physics_processing()
	self.set_physics_process(true)
	if self.global_position != target_position:
		self.resume_move_to(target, speed)
		await self.move_to_done

	self.move_timer = null
	self.global_position = target_position
	self.velocity = Vector2.ZERO
	self.set_physics_process(was_processing_physics)

func pause_move_to():
	if self.move_timer != null:
		self.move_timer.timeout.disconnect(self.on_move_timer_done)

func resume_move_to(target: Array, speed):
	var target_position = Vector2(
		target[0] if target[0] != null else self.global_position.x,
		target[1] if target[1] != null else self.global_position.y
	)
	var time = (self.global_position - target_position).length()/speed
	
	if time > 0:
		self.velocity = (target_position - self.global_position).normalized() * speed
		self.move_timer = self.get_tree().create_timer(time, false)
		self.move_timer.timeout.connect(self.on_move_timer_done, CONNECT_ONE_SHOT)
	else:
		self.move_to_done.emit()

func skip_move_to():
	self.move_to_done.emit()
	
func on_move_timer_done():
	self.move_to_done.emit()

func on_battle_start():
	self.battler.on_battle_start()

func on_battle_end():
	self.battler.on_battle_end()
