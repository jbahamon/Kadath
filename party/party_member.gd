# Represents a playable character to add in the player's party
# Holds the data and nodes for the character's battler, anim,
# and the character's stats to save the game
extends Node2D

class_name PartyMember

enum Id {
	ARDEN = 1 << 0
	ZOOG = 1 << 1,
	KIT = 1 << 2,
	LENG = 1 << 3,
	UPTON = 1 << 4,
	KURANES = 1 << 5,
}

onready var battler = $Battler

export (Id) var id: int = Id.ARDEN
export var display_name: String
export var growth: Resource
export var unlocked = false
export var experience: int setget _set_experience
export var icon: Texture

onready var SAVE_KEY: String = "party_member_" + name

var equipped_weapon: Weapon setget set_weapon
var equipped_helmet: Helmet setget set_helmet
var equipped_armor: Armor setget set_armor
var equipped_accessory: Accessory setget set_accessory

func _ready():
	assert(growth)
	battler.is_party_member = true
	battler.stats = growth.create_stats(experience)


func update_stats():
	if battler == null:
		return
	# Update this character's stats to match select changes
	# that occurred during combat or through menu actions
	var before_level = battler.stats.level
	var after_level = growth.get_level(experience)
	if before_level != after_level:
		battler.stats = growth.create_stats(experience)

func _set_experience(value: int):
	experience = max(0, value)
	update_stats()

func get_physical_attack_bonus() -> float:
	return float(equipped_weapon.attack if equipped_weapon != null else 0)
	
func get_physical_armor() -> float:
	return float(
		(equipped_armor.defense if equipped_armor != null else 0) +
		(equipped_armor.defense if equipped_armor != null else 0)
	)
	
func get_elemental_armor() -> float:
	return 0.0

func save(save_game: Resource):
	save_game.data[SAVE_KEY] = {
		'display_name': display_name,
		'unlocked': unlocked,
		'equipped_weapon': equipped_weapon,
		'equipped_helmet': equipped_helmet,
		'equipped_armor': equipped_armor,
		'equipped_accessory': equipped_accessory,
		'experience': experience,
		'health': battler.stats.health,
		'energy': battler.stats.energy,
	}


func load(save_game: Resource):
	var data: Dictionary = save_game.data[SAVE_KEY]
	display_name = data['display_name']
	unlocked = data['unlocked']
	
	equipped_weapon = data['equipped_weapon']
	equipped_helmet = data['equipped_helmet']
	equipped_armor = data['equipped_armor']
	equipped_accessory = data['equipped_accessory']
	
	experience = data['experience']
	battler.stats = growth.create_stats(experience)
	
	battler.stats.health = data['health']
	battler.stats.energy = data['energy']
	
func set_weapon(weapon: Weapon):
	var party: Party = self.get_parent()
	assert(party != null || equipped_weapon == null)
	if party != null:
		if equipped_weapon != null:
			party.inventory.add(equipped_weapon)
		party.inventory.remove(weapon)
	
	equipped_weapon = weapon
	

func set_helmet(helmet: Helmet):
	var party: Party = self.get_parent()
	assert(party != null || equipped_helmet == null)
	if party != null:
		if equipped_helmet != null:
			party.inventory.add(equipped_helmet)
		party.inventory.remove(helmet)
	
	equipped_helmet = helmet
	
func set_armor(armor: Armor):
	var party: Party = self.get_parent()
	assert(party != null || equipped_armor == null)
	if party != null:
		if equipped_armor != null:
			party.inventory.add(equipped_armor)
		party.inventory.remove(armor)
	
	equipped_armor = armor
	
func set_accessory(accessory: Accessory):
	var party: Party = self.get_parent()
	assert(party != null || equipped_accessory == null)
	if party != null:
		if equipped_accessory != null:
			party.inventory.add(equipped_accessory)
		party.inventory.remove(accessory)
	
	equipped_accessory = accessory
