# Container for the player's party
# Holds all playable game characters whether the player
# has already unlocked them or not in the game.
# After an encounter, it delegates stats update (experience and health) to each
# active party member
extends Node2D

class_name Party

export var PARTY_SIZE: int = 3

const inventory_save_key = "Inventory"

var inventory: Inventory = Inventory.new()

func load(save_data: SaveData) -> void:
	inventory.load(save_data)
	
func save(save_data: SaveData) -> void:
	inventory.save(save_data)
	
func get_active_members() -> Array:
	# Returns the first unlocked children until the party is filled
	var active = []
	var available = get_unlocked_characters()
	for i in range(min(len(available), PARTY_SIZE)):
		active.append(available[i])
	return active

func get_unlocked_characters() -> Array:
	# Returns all the characters that can be active in the party
	var has_unlocked = []
	for member in get_children():
		if member.unlocked:
			has_unlocked.append(member)
	return has_unlocked

func get_anim():
	return self.get_active_members()[0].get_anim()
