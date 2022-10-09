extends Node

signal battle_ended(won)

# The Battle should handle initialization: this is, connecting characters
# to the loop, and handling restoring everything to its normal state once the 
# battle has finished

onready var ui: BattleUI = $CanvasLayer/BattleUI

func start(room: LocationRoom, party: Party, non_party_actors: Array, positioning_vars):
	var party_actors = party.get_active_members()
	
	for party_actor in party_actors:
		party.remove_child(party_actor)
		room.add_child(party_actor)
		
	yield(
		self.set_up_battle_positions(
			positioning_vars["current_position"],
			party_actors, 
			non_party_actors
		), 
		"completed"
	)
	
	
	var actors = party_actors + non_party_actors
		
	BattleLoop.initialize(actors, ui)
	self.ui.initialize(party_actors)
	self.ui.show()
	
	# wait until starting anims/positioning are done
	var battle_end_state = BattleLoop.do_battle()
	
	if battle_end_state is GDScriptFunctionState:
		battle_end_state = yield(battle_end_state, "completed")

	if battle_end_state.player_won: 
		var state = self.deal_rewards(party, battle_end_state.rewards)
		if state is GDScriptFunctionState:
			yield(state, "completed")
	else:
		print("game over :(")
		
	self.ui.hide()
	
	# TODO: return party to position, return party members to party
	
	emit_signal("battle_ended", battle_end_state.player_won)

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
	cutscene_lines.append("MOVE_CAMERA TO (%d, %d) IN 2" % [int(round(battle_spot.position.x)), int(round(battle_spot.position.y))])
	
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

	# get closest battle_spot node
	var local_scene = get_parent()
	yield(local_scene.play_custom_cutscene(cutscene_lines), "completed")
	
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
	# EXP
	var experience = rewards.experience
	if experience > 0:
		yield(deal_experience(party, experience), "completed")
	var items = rewards.items
	if items.size() > 0:
		yield(deal_items(party, items), "completed")
	
	if rewards.money > 0:
		yield(deal_money(party, rewards.money), "completed")
		 
func deal_experience(party: Party, experience: int):
	yield(self.ui.prompt("Gained %d experience points!" % experience), "completed")
	for party_member in party.get_active_members():
		if !party_member.battler.is_alive():
			continue
			
		var previous_level = party_member.get_level()
		# TODO: include support party members
	
		party_member.experience += experience
		party_member.update_stats()
		
		if previous_level != party_member.get_level():
			yield(self.ui.prompt("%s leveled up" % party_member.display_name), "completed")

func deal_items(party: Party, loot_bag: Array):
	for loot in loot_bag:
		yield(self.ui.prompt("Received %s!" % loot.item.name), "completed")
		party.inventory.add(loot.item, loot.amount)

func deal_money(party: Party, money: int):
	yield(self.ui.prompt("Received %d G!" % money), "completed")
	# party.inventory.money
	
