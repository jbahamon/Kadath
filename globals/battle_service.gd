extends Node
const BattleLoop = preload("res://battle/battle_loop.gd")

enum Event {
	TURN_START,
	TURN_END,
	BATTLE_END
}
enum Subscription {
	FIRE_ONCE,
	FIRE_ALWAYS
}

# The Battle should handle initialization: this is, connecting characters
# to the loop, and handling restoring everything to its normal state once the 
# battle has finished

var loop
var ui: BattleUI

func _init():
	self.loop = BattleLoop.new()

func initialize(init_ui: BattleUI):
	self.ui = init_ui

func start_battle(non_party_actors: Array, enemy_position: Vector2):
	assert(enemy_position != null)
	
	InputService.disable_inputs()
	var world = EnvironmentService.get_world()
	
	var previous_parent = CameraService.assign_camera(EnvironmentService.get_world())
	
	var positioning_vars = {
		"current_position": CameraService.get_camera_position()
	}
	
	var actor_names = {}
	for actor in non_party_actors:
		actor_names[actor.name] = true
	
	var elements_hidden_for_battle = []
	
	for child in world.get_children():
		if (child.is_in_group("npc") and 
			child.visible and
			not actor_names.get(child.name, false)):
			self.elements_hidden_for_battle.append(child)
			child.visible = false

	var _proc = self.player_proxy.is_physics_processing()
	var party = EntitiesService.get_party()
	var party_actors = EntitiesService.get_active_party_members()
	var room = EnvironmentService.get_room()
	
	for party_actor in party_actors:
		party.remove_child(party_actor)
		room.add_child(party_actor)
		
	await self.set_up_battle_positions(
			positioning_vars["current_position"],
			party_actors, 
			non_party_actors
		)
	
	var actors = party_actors + non_party_actors

	self.loop.initialize(actors, self.ui)
	self.ui.initialize(party_actors)
	self.ui.show()
	
	# wait until starting anims/positioning are done
	var battle_end_state = await self.loop.do_battle()
	
	if battle_end_state.player_won: 
		await self.deal_rewards(party, battle_end_state.rewards)
	else:
		print("game over :(")
		
	self.ui.hide()
	
	# TODO: return party to position, return party members to party
	
	CameraService.assign_camera(previous_parent)
	
	# move to game over scene if player lost
	for element in self.elements_hidden_for_battle:
		element.visible = true
	
	InputService.enable_inputs()

func set_up_battle_positions(current_position: Vector2, party_actors: Array, non_party_actors: Array):
	var battle_spot = self.get_nearest_battle_spot(current_position)
	assert(battle_spot != null)
	
	var party_spots = battle_spot.party_spots.get_children()
	var enemy_spots = battle_spot.enemy_spots.get_children()
	
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
		"MOVE_CAMERA TO (%d, %d) IN 2" % [
			int(round(battle_spot.position.x)), 
			int(round(battle_spot.position.y))
		]
	)
	
	for i in range(party_actors.size()): 
		var party_actor = party_actors[i]
		var spot = party_spots[i]
		cutscene_lines.append(
			"WALK %s TO (%d, %d) AT 30" % [
				party_actor.name, 
				int(round(spot.position.x)), 
				int(round(spot.position.y))
			]
		)
	
	for non_party_actor in non_party_actors: 
		var spot = spots_by_name[non_party_actor.display_name].pop_back()
		cutscene_lines.append(
			"WALK %s TO (%d, %d) AT 30" % [
				non_party_actor.name, 
				int(round(spot.position.x)), 
				int(round(spot.position.y))
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

	
