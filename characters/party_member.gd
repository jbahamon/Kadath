# Represents a playable character to add in the player's party
# Holds the data and nodes for the character's battler, pawn on the map,
# and the character's stats to save the game
extends Node

class_name PartyMember

signal level_changed(new_value, old_value)

export var display_name: String
export var anim_path: NodePath
export var growth: Resource
export var unlocked = false
export var experience: int setget _set_experience
var stats: Resource

onready var battler: Battler = $Battler
onready var SAVE_KEY: String = "party_member_" + name

var equip_weapon: Equipment
var equip_head: Equipment
var equip_body: Equipment
var equip_accessory: Equipment


func _ready():
	assert(anim_path)
	assert(growth)
	# TODO
	# stats = growth.create_stats(experience)
	# battler.stats = stats


func update_stats(before_stats: CharacterStats):
	# Update this character's stats to match select changes
	# that occurred during combat or through menu actions
	var before_level = before_stats.level
	var after_level = growth.get_level(experience)
	if before_level != after_level:
		stats = growth.create_stats(experience)
		emit_signal("level_changed", after_level, before_level)
	battler.stats = stats


func get_battler_copy():
	# Returns a copy of the battler to add to the CombatArena
	# at the start of a battle
	return battler.duplicate()


func get_pawn_anim():
	# Returns a copy of the PawnAnim that represents this character,
	# e.g. to add it as a child of the currently loaded game map
	return get_node(anim_path).duplicate()


func _set_experience(value: int):
	if value == null:
		return
	experience = max(0, value)
	if stats:
		update_stats(stats)


func save(save_game: Resource):
	save_game.data[SAVE_KEY] = {
		'display_name': display_name,
		'unlocked': unlocked,
		'equip_weapon': equip_weapon,
		'equip_head': equip_head,
		'equip_body': equip_body,
		'equip_accessory': equip_accessory,
		'experience': experience,
		'health': stats.health,
		'mana': stats.mana,
	}


func load(save_game: Resource):
	var data: Dictionary = save_game.data[SAVE_KEY]
	display_name = data['display_name']
	unlocked = data['unlocked']
	
	equip_weapon = data['equip_weapon']
	equip_head = data['equip_head']
	equip_body = data['equip_body']
	equip_accessory = data['equip_accessory']
	
	experience = data['experience']
	# TODO
	# stats = growth.create_stats(experience)
	
	stats.health = data['health']
	stats.mana = data['mana']
	
