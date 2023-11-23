# Container for the player's party
# Holds all playable game characters whether the player
# has already unlocked them or not in the game.
# After an encounter, it delegates stats update (experience and health) to each
# active party member
extends Node

class_name Party

@export var PARTY_SIZE: int = 3

const inventory_save_key = "Inventory"

var inventory: Inventory = Inventory.new()
var display_name = "party" # : get = get_display_name
var active_members: Array

const MOVEMENT_STANDING_OFFSET = 8
const MOVEMENT_MOVING_OFFSET = 16

var movement_cache: Array
var movement_cache_index: int
var movement_pointers: Array

func _ready():
	self.update_active_members()
	self.set_process(false)
	self.movement_cache = []
	self.movement_cache.resize(
		max(MOVEMENT_STANDING_OFFSET, MOVEMENT_STANDING_OFFSET) * PARTY_SIZE
	)
	self.movement_pointers = []
	self.movement_pointers.resize(PARTY_SIZE)
	
func on_proxy_enter(proxy: PlayerProxy):
	self.movement_pointers.fill(0)
	
	for party_member in self.active_members:
		party_member.position = proxy.position
		party_member.set_orientation(proxy.current_orientation)
	
func _physics_process(delta):
	var proxy: PlayerProxy = EntitiesService.get_proxy()
	if proxy.velocity != Vector2.ZERO and active_members.size() > 1:
		print("storing things")
		self.movement_cache[self.movement_pointers[0]] = {
			"position": proxy.global_position,
			"orientation": proxy.current_orientation,
			"anim": self.active_members[0].get_current_anim()
		}
		
		self.movement_pointers[0] = (self.movement_pointers[0] + 1) % self.movement_cache.size()
		
	
	if active_members.size() > 1:
		var offset = MOVEMENT_MOVING_OFFSET if proxy.velocity != Vector2.ZERO else MOVEMENT_STANDING_OFFSET
		var leader_idx = self.movement_pointers[0]
		for i in range(1, active_members.size()):
			var idx = self.movement_pointers[i]
			if posmod(leader_idx - idx, self.movement_cache.size()) > offset:
				active_members[i].global_position = movement_cache[idx]["position"]
				active_members[i].set_orientation(movement_cache[idx]["orientation"])
				active_members[i].play_anim(movement_cache[idx]["anim"])
				self.movement_pointers[i] = (idx + 1) % self.movement_cache.size()
			elif proxy.velocity == Vector2.ZERO:
				active_members[i].play_anim(self.active_members[0].get_current_anim())

func load_game_data(save_data: SaveData) -> void:
	inventory.load_game_data(save_data)
	self.update_active_members()
	
func save(save_data: SaveData) -> void:
	inventory.save(save_data)
	
func update_active_members():
	# Updates active members with the first unlocked children until the party is filled
	var active = []
	var available = get_unlocked_characters()
	var i = 0;
	for party_member in available:
		if i < PARTY_SIZE:
			party_member.visible = true
			active.append(party_member)
		else:
			party_member.visible = false
	
	self.active_members = active
	# since this is called during game initialization, some globals might not be there
	if EntitiesService != null:
		var proxy: PlayerProxy = EntitiesService.get_proxy()
		if proxy != null and proxy.current_target_type == PlayerProxy.TargetType.PARTY:
			proxy.set_target(self, true)

func get_unlocked_characters() -> Array:
	# Returns all the characters that can be active in the party
	var has_unlocked = []
	for member in get_children():
		if member.unlocked:
			has_unlocked.append(member)
	return has_unlocked
	
func get_display_name() -> String:
	return self.active_members[0].display_name
	
func play_anim(anim_name: String):
	self.active_members[0].play_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	self.active_members[0].set_orientation(orientation)
	
func unlock(id: PartyMember.Id):
	for member in get_children():
		if member.id == id:
			member.unlock()
			self.update_active_members()
			return

func get_leader():
	return self.active_members[0]

func add_to_room():
	var room = EnvironmentService.get_room()
	var last_added_child = null
	for i in range(active_members.size() - 1, -1, -1):
		var party_member = active_members[i]
		self.remove_child(party_member)
		room.add_child(party_member)
	
func remove_from_room():
	var room = EnvironmentService.get_room()
	
	var last_added_child = null
	for party_member in active_members:
		room.remove_child(party_member)
		if last_added_child == null:
			self.add_child(party_member)
			self.move_child(party_member, 0)
		else:
			last_added_child.add_sibling(party_member)

		last_added_child = party_member

	
