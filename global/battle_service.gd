extends Node
const BattleLoop = preload("res://battle/battle_loop.gd")
const Attack = preload("res://battle/action/attack.gd")

enum Event {
	TURN_START,
	TURN_END,
	BATTLE_END
}
enum Subscription {
	FIRE_ONCE,
	FIRE_ALWAYS
}

# The Battle Service should handle initialization: this is, connecting characters
# to the loop, and handling restoring everything to its normal state once the 
# battle has finished

var loop
var ui: BattleUI

var current_battle_parameters = null
var common_action_options = {}

func _init():
	self.loop = BattleLoop.new()
	self.init_common_action_options()

func initialize(init_ui: BattleUI):
	self.ui = init_ui

func init_common_action_options():
	var attack = Attack.new()
	attack.display_name = "Attack"
	attack.description = "Attack with the equipped weapon"
	self.common_action_options["attack"] = attack
	
func start_mook_battle(escapable: bool):
	
	if self.current_battle_parameters != null: 
		return
		
	var rect: Rect2i = CameraService.get_visible_rect()
	var mooks = []
	var world = EnvironmentService.get_world()
	var enemies = world.get_tree().get_nodes_in_group("enemy")
	for mook in enemies:
		if rect.has_point(Vector2i(mook.position)):
			mooks.append(mook)
	
	self.start_battle(mooks, escapable)

func start_battle(non_party_actors: Array, escapable: bool):
	if self.current_battle_parameters != null:
		return
	
	self.current_battle_parameters = {
		"escapable": escapable
	}
	
	var camera_position = CameraService.get_camera().get_screen_center_position()
	var battle_spot = self.get_nearest_battle_spot(camera_position)

	if battle_spot.get_enemy_spots().size() < non_party_actors.size():
		non_party_actors.sort_custom(
			func(a: Node2D, b: Node2D): 
				return (
					a.position.distance_squared_to(camera_position) < 
					b.position.distance_squared_to(camera_position)
				)
		)
		non_party_actors = non_party_actors.slice(0, battle_spot.get_enemy_spots().size())
	
	var world = EnvironmentService.get_world()
	var hidden_npcs = []

	for npc in world.get_tree().get_nodes_in_group("npc"):
		if npc not in non_party_actors and npc.visible:
			hidden_npcs.append(npc)
			npc.pause()
			npc.visible = false
			
	var proxy = EntitiesService.get_proxy()
	proxy.pause()
	
	var party = EntitiesService.get_party()
	var party_actors = EntitiesService.get_active_party_members()
	var room = EnvironmentService.get_room()
	
	for party_actor in party_actors:
		party.remove_child(party_actor)
		room.add_child(party_actor)
		party_actor.set_position(party_actor.position + party.position)

	var actors = party_actors + non_party_actors

	self.loop.initialize(actors, self.ui)
	self.ui.initialize(party_actors)

	# cutscene
	await self.set_up_battle_positions(battle_spot, party_actors, non_party_actors)
	
	# just to ensure we're not keeping references to enemies that might be freed during battle
	non_party_actors = []
	actors = []
	
	self.ui.show()
	var battle_end_state = await self.loop.do_battle()
	
	if battle_end_state.player_won: 
		await self.deal_rewards(party, battle_end_state.rewards)
	else:
		print("game over :(")
		
	self.ui.hide()
	
	# TODO: return party to position, return party members to party
	# move to game over scene if player lost
	for npc in self.hidden_npcs:
		npc.resume()
		npc.visible = true
	
	proxy.resume()
	self.current_battle_parameters = null

func set_up_battle_positions(battle_spot, party_actors: Array, non_party_actors: Array):
	var party_spots = battle_spot.get_party_spots()
	var enemy_spots = battle_spot.get_enemy_spots()
	
	var spots_by_name = {}
	for spot in enemy_spots:
		if not spot.enemy in spots_by_name:
			spots_by_name[spot.enemy] = [spot]
		else:
			spots_by_name[spot.enemy].append(spot)

	# move camera to it in X time
	
	var cutscene_lines = []
	cutscene_lines.append("SIMULTANEOUS")
	cutscene_lines.append(
		"MOVE_CAMERA TO (%d, %d) IN 0.5" % [
			int(round(battle_spot.global_position.x)), 
			int(round(battle_spot.global_position.y))
		]
	)
	
	for i in range(party_actors.size()): 
		var party_actor = party_actors[i]
		var spot = party_spots[i]
		cutscene_lines.append(
			"WALK %s TO (%d, %d) AT 50" % [
				party_actor.name, 
				int(round(spot.global_position.x)), 
				int(round(spot.global_position.y))
			]
		)
	
	for non_party_actor in non_party_actors: 
		var spot = spots_by_name[non_party_actor.display_name].pop_back()
		cutscene_lines.append(
			"WALK %s TO (%d, %d) AT 50" % [
				non_party_actor.name, 
				int(round(spot.global_position.x)), 
				int(round(spot.global_position.y))
			]
		)
	
	cutscene_lines.append("END")

	await CutsceneService.play_custom_cutscene(cutscene_lines)
	
func get_nearest_battle_spot(current_position: Vector2):
	var battle_spots = get_tree().get_nodes_in_group("battle_spot")
	var min_distance = INF
	var nearest_spot = null
	
	for battle_spot in battle_spots:
		var distance = (current_position - battle_spot.position).length()
		if distance < min_distance:
			min_distance = distance
			nearest_spot = battle_spot
			
	return nearest_spot

func deal_rewards(party: Party, rewards: BattleRewards):
	var experience = rewards.experience
	if experience > 0:
		await deal_experience(party, experience)
		
	var items = rewards.items
	if items.size() > 0:
		await deal_items(party, items)
	
	if rewards.money > 0:
		await deal_money(party, rewards.money)

func deal_experience(party: Party, experience: int):
	await self.ui.prompt("Gained %d experience points!" % experience)
	for party_member in party.get_active_members():
		if !party_member.battler.is_alive():
			continue
			
		var previous_level = party_member.get_level()
		# TODO: include support party members
	
		party_member.experience += experience
		party_member.update_stats()
		
		if previous_level != party_member.get_level():
			await self.ui.prompt("%s leveled up" % party_member.display_name)

func deal_items(party: Party, loot_bag: Array):
	for loot in loot_bag:
		await self.ui.prompt("Received %s!" % loot.item.name)
		party.inventory.add(loot.item, loot.amount)

func deal_money(_party: Party, money: int):
	await self.ui.prompt("Received %d G!" % money)
	# WIP
	# party.inventory.money
	
func subscribe_to_event(subscriber, event, subscription_type):
	self.loop.subscribe_to_event(subscriber, event, subscription_type)
	
func add_rewards(rewards):
	self.loop.add_rewards(rewards)

func remove_actor(actor):
	self.loop.remove_actor(actor)

	
