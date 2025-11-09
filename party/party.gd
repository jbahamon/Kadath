# Container for the player's party
# Holds all playable game characters whether the player
# has already unlocked them or not in the game.
# After an encounter, it delegates stats update (experience and health) to each
# active party member
extends Node

class_name Party

const party_icons = {
	PartyMember.Id.ALEX: preload("res://party/alex/icon.png"),
	PartyMember.Id.VOLKI: preload("res://party/carter/icon.png"),
	PartyMember.Id.GRUSKA: preload("res://party/carter/icon.png"),
	PartyMember.Id.SYLVIE: preload("res://party/carter/icon.png"),
	PartyMember.Id.PICKMAN: preload("res://party/pickman/icon.png"),
	PartyMember.Id.KURANES: preload("res://party/carter/icon.png"),
	PartyMember.Id.ZKAUBA: preload("res://party/carter/icon.png"),
	PartyMember.Id.CARTER: preload("res://party/carter/icon.png"),
}

@export var PARTY_SIZE: int = 3

const inventory_save_key = "Inventory"

var inventory: Inventory = Inventory.new()
var display_name = "party"
var active_members: Array

const MOVEMENT_STANDING_OFFSET = 8
const MOVEMENT_MOVING_OFFSET = 16

var movement_cache: Array
var movement_cache_index: int
var movement_pointers: Array

func _ready():
	self.set_physics_process(false)
	self.movement_cache = []
	self.movement_cache.resize(
		max(MOVEMENT_STANDING_OFFSET, MOVEMENT_STANDING_OFFSET) * PARTY_SIZE
	)
	self.movement_pointers = []
	self.movement_pointers.resize(PARTY_SIZE)

func on_proxy_enter(_proxy: PlayerProxy):
	self.set_physics_process(true)
	self.reset_movement()

func clear_movement_buffers():
	self.movement_pointers.fill(0)
	
func reset_movement():
	var leader = self.get_leader()
	self.clear_movement_buffers()
	
	# This is a bit of a weird fix.
	# The proxy doesn't update the proxied entity's position right away. 
	# So when resetting movement, the leader might not be in the 
	# proxy's position/orientation. We enforce it
	
	var proxy = EntitiesService.proxy
	if proxy.current_target_type == PlayerProxy.TargetType.PARTY:
		leader.position = proxy.position
		leader.set_orientation(proxy.current_orientation)
	
	for party_member in self.active_members:
		party_member.position = leader.position
		party_member.set_orientation(leader.current_orientation)
	
	
func on_proxy_exit(_proxy: PlayerProxy):
	self.set_physics_process(false)
	
func _physics_process(_delta):
	if not self.is_physics_processing():
		# This is needed because sometimes (e.g. on interaction) party imitation
		# must be stopped while processing a physics frane
		return
		
	var proxy: PlayerProxy = EntitiesService.proxy
	if proxy.velocity != Vector2.ZERO and active_members.size() > 1:
		
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
	
	# we load every member first
	for party_member in self.active_members:
		party_member.load_game_data(save_data)
		
	for party_member in self.get_children():
		party_member.load_game_data(save_data)
		
	var i = 0
	
	var ordering = {}
	for party_member_name in save_data.data["party_order"]:
		ordering[party_member_name] = i
		i += 1
		
	self.update_active_members(ordering)
	
func save_game_data(save_data: SaveData) -> void:
	inventory.save_game_data(save_data)
	var party_order = []
	for party_member in self.active_members:
		party_member.save_game_data(save_data)
		party_order.append(party_member.name)
	for party_member in self.get_children():
		party_member.save_game_data(save_data)
		party_order.append(party_member.name)
		
	save_data.data["party_order"] = party_order

func update_active_members(ordering=null):
	var new_ordered_members = self.get_unlocked_characters()
	var current_parent = self.active_members[0].get_parent() if self.active_members.size() > 0 else null
	
	if ordering != null:
		new_ordered_members.sort_custom(func(a, b): return ordering[a.name] < ordering[b.name])
	
	var new_active_members = []
	var i = 0;
	var last_added_child = null
	for party_member in new_ordered_members:
		var parent = party_member.get_parent()
		if parent != null:
			parent.remove_child(party_member)
		
		if i < PARTY_SIZE:
			new_active_members.append(party_member)
			party_member.visible = true
			if current_parent != null:
				current_parent.add_child(party_member)
		else:
			party_member.visible = false
			if last_added_child == null:
				self.add_child(party_member)
				self.move_child(party_member, 0)
			else:
				last_added_child.add_sibling(party_member)

			last_added_child = party_member
			
	self.active_members = new_active_members


func get_unlocked_characters() -> Array:
	# Returns all the characters that can be active in the party
	var has_unlocked = []
	
	for member in active_members:
		if member.unlocked and member.get_parent() != self:
			has_unlocked.append(member)
			
	for member in get_children():
		if member.unlocked:
			has_unlocked.append(member)
	return has_unlocked
	
func get_display_name() -> String:
	return self.active_members[0].display_name
	
func play_anim(anim_name: String):
	for member in self.active_members:
		member.play_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	for member in self.active_members:
		member.set_orientation(orientation)
	
func set_unlocked(id: PartyMember.Id, unlocked: bool):
	for member in (self.active_members + get_children()):
		if member.id == id:
			if member.unlocked != unlocked:
				member.unlocked = unlocked
				
				self.remove_from_room()
				self.update_active_members()
				self.add_to_room()

			return

func is_unlocked(id: PartyMember.Id):
	return (
		self.active_members.any(func(member): return member.id == id and member.unlocked) or
		self.get_children().any(func(member): return member.id == id and member.unlocked)
	)
	
func get_leader():
	return self.active_members[0]

func add_to_room():
	var room = EnvironmentService.current_room
	for i in range(self.active_members.size()):
		room.add_child(self.active_members[self.active_members.size() - 1 - i])
	
func remove_from_room():
	for party_member in active_members:
		var parent = party_member.get_parent()
		if parent != null:
			parent.remove_child(party_member)

func get_active_members():
	return self.active_members

func get_inactive_members():
	return self.get_children()
