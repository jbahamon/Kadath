extends Node

const BattleLoop = preload("res://battle/battle_loop.gd")
const Attack = preload("res://battle/action/party_member_attack.gd")
const Defend = preload("res://battle/action/defend.gd")
const Win = preload("res://battle/action/win.gd")
const Lose = preload("res://battle/action/lose.gd")
const Item = preload("res://battle/action/item.gd")	
const Escape = preload("res://battle/action/escape.gd")
const BattleEndState = preload("res://battle/battle_end_state.gd")

const FadeOverlay = preload("res://utils/cutscene_manager/instructions/fade_overlay.gd")

enum Event {
	TURN_START,
	TURN_END,
	BEFORE_ACTOR_DEATH,
	AFTER_ACTOR_DEATH
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

func exit():
	self.ui = null
	self.current_battle_parameters = {}
	
func init_common_action_options():
	var attack = Attack.new()
	attack.display_name = "Attack"
	attack.description = "Attack with the equipped weapon."
	self.common_action_options["attack"] = attack
	
	var defend = Defend.new()
	defend.display_name = "Defend"
	defend.description = "Raise this party member's defenses until their next turn."
	self.common_action_options["defend"] = defend
	
	var win = Win.new()
	win.display_name = "Win"
	win.description = "Win the battle."
	self.common_action_options["win"] = win
	
	var lose = Lose.new()
	lose.display_name = "Lose"
	lose.description = "Lose the battle."
	self.common_action_options["lose"] = lose
	
	var item = Item.new()
	item.display_name = "Item"
	item.description = "Use an item."
	self.common_action_options["item"] = item
	
	var escape = Escape.new()
	escape.display_name = "Escape"
	escape.description = "Try to run away."
	self.common_action_options["escape"] = escape
	
func start_mook_battle(escapable: bool):
	if self.current_battle_parameters != null: 
		return
		
	var rect: Rect2i = CameraService.get_visible_rect()
	
	var world = EnvironmentService.get_world()
	var enemies = world.get_tree().get_nodes_in_group("enemy")
	var mooks = enemies.filter(func(mook): return rect.has_point(Vector2i(mook.position)))

	self.start_battle(mooks, escapable)

func start_battle(enemies: Array, escapable: bool, proxy_mode_on_finish=null):
	if self.current_battle_parameters != null:
		return
	
	self.current_battle_parameters = {
		"escapable": escapable,
		"escape_tries": 0,
	}
	
	var was_input_enabled = InputService.is_input_enabled()
	InputService.set_input_enabled(false)
	var end_proxy_mode = (
		proxy_mode_on_finish 
		if proxy_mode_on_finish != null 
		else EntitiesService.get_proxy().current_mode
	)
	var battle_spot = self.get_nearest_battle_spot()
	var non_party_actors = self.filter_non_party_actors(enemies, battle_spot)
	self.pause_non_participants(non_party_actors)
	
	var party_actors = EntitiesService.get_active_party_members()
	var actors = party_actors + non_party_actors

	self.loop.initialize(actors, self.ui)
	self.ui.initialize(party_actors)

	# starting cutscene
	await self.set_up_battle_positions(battle_spot, party_actors, non_party_actors)
	self.rename_non_party_actors(non_party_actors)
	
	# just to ensure we're not keeping references to enemies that might be freed during battle
	non_party_actors = []
	actors = []
	
	self.ui.start()
	var battle_end_state = await self.loop.do_battle()
	
	match battle_end_state.result:
		BattleEndState.Result.ESCAPE:
			self.ui.hide()
			await self.fade_and_delete_mooks(battle_end_state)
			await self.tear_down_battle_positions(battle_end_state)
			self.resume_non_participants(end_proxy_mode)
			InputService.set_input_enabled(was_input_enabled)
		BattleEndState.Result.WIN:
			await self.deal_rewards(battle_end_state.rewards)
			self.ui.hide()
			self.revive_party_members(EntitiesService.get_party())
			await self.tear_down_battle_positions(battle_end_state)
			self.resume_non_participants(end_proxy_mode)
			InputService.set_input_enabled(was_input_enabled)
		BattleEndState.Result.LOSE: 
			self.ui.hide()
			var party = EntitiesService.get_party()
			party.set_physics_process(false)
			LayersService.get_layer("MIX").color = Color(0,0,0,0)
			await FadeOverlay.new("MIX", Color.BLACK, 3.0).execute(get_tree(), FadeOverlay.ExecutionMode.PLAY)
			SceneSwitcher.current_scene.exit()
			SceneSwitcher.go_to_scene("res://ui/04_templates/other/demo_end.tscn")
			print("game over :(")
			
	self.current_battle_parameters = null

func get_actors():
	return self.loop.actors

func get_nearest_battle_spot():
	var camera_position = CameraService.get_camera().get_screen_center_position()
	var battle_spots = get_tree().get_nodes_in_group("battle_spot")
	var min_distance = INF
	var nearest_spot = null
	
	for battle_spot in battle_spots:
		var distance = (camera_position - battle_spot.position).length()
		if distance < min_distance:
			min_distance = distance
			nearest_spot = battle_spot
			
	return nearest_spot

func filter_non_party_actors(non_party_actors: Array, battle_spot):
	if battle_spot.get_enemy_spots().size() < non_party_actors.size():
		var camera_position = CameraService.get_camera().get_screen_center_position()

		non_party_actors.sort_custom(
			func(a: Node2D, b: Node2D): 
				return (
					a.position.distance_squared_to(camera_position) < 
					b.position.distance_squared_to(camera_position)
				)
		)
		return non_party_actors.slice(0, battle_spot.get_enemy_spots().size())
	else:
		return non_party_actors

func rename_non_party_actors(non_party_actors: Array):
	var actors_dict ={}
	
	for actor in non_party_actors:
		if not actors_dict.has(actor.display_name):
			actors_dict[actor.display_name] = [actor]
		else:
			actors_dict[actor.display_name].append(actor)
	
	# We assume here that there's not gonna be over 16 identical enemies on a
	# battle, which seems reasonable
	var suffix: String = "ABCDEFGHIJKLMNOP"
	for actor_name in actors_dict:
		var actors = actors_dict[actor_name]
		if actors.size() > 1:
			actors.sort_custom(
				func(a: Node2D, b: Node2D):
					return a.position.x < b.position.x
			)
			
			for i in range(actors.size()):
				actors[i].instance_id = suffix[i % suffix.length()]
	

func set_up_battle_positions(battle_spot, party_actors: Array, non_party_actors: Array):
	var party: Party = EntitiesService.get_party()
	party.set_physics_process(false)
	
	var party_spots = battle_spot.get_party_spots()
	var enemy_spots = battle_spot.get_enemy_spots()
	
	var spots_by_name = {}
	for spot in enemy_spots:
		if not spot.enemy in spots_by_name:
			spots_by_name[spot.enemy] = [spot]
		else:
			spots_by_name[spot.enemy].append(spot)

	var cutscene_lines = []
	
	cutscene_lines.append("SIMULTANEOUS")
	cutscene_lines.append(
		"MOVE_CAMERA TO (%d, %d) IN 0.5" % [
			int(round(battle_spot.global_position.x)), 
			int(round(battle_spot.global_position.y))
		]
	)
	
	var target_spots = []
	var non_party_lines = []
	for non_party_actor in non_party_actors:
		non_party_actor.on_battle_start()
		var key = non_party_actor.display_name
		var spots = spots_by_name.get(key)
		if spots == null:
			key = "*"
			spots = spots_by_name.get(key)
		
		var spot = self.get_closest_to(spots, non_party_actor.global_position)
		if spots.size() > 1:
			spots.erase(spot)
		else:
			spots_by_name.erase(key)
			
		non_party_lines.append(
			[
				non_party_actor,
				"WALK %s TO (%d, %d) AT 50" % [
					non_party_actor.name, 
					int(round(spot.global_position.x)), 
					int(round(spot.global_position.y))
				]
			]
		)
		target_spots.append(spot)
		
	var used_spots = []
	
	for i in range(party_actors.size()): 
		var party_actor = party_actors[i]
		party_actor.on_battle_start()
		var spot = party_spots[i]
		var closest_enemy = self.get_closest_to(target_spots, spot.global_position)
		
		used_spots.append(spot)
		cutscene_lines.append_array(
			[
				"SEQUENTIAL",
				"RUN %s TO (%d, %d) AT 85" % [
					party_actor.name, 
					int(round(spot.global_position.x)), 
					int(round(spot.global_position.y))
				],
				"LOOK_AT %s AT (%d, %d)" % [
					party_actor.name, 
					int(round(closest_enemy.global_position.x)), 
					int(round(closest_enemy.global_position.y))
				],
				"PLAY_ANIM %s battle_idle" % party_actor.name,
				"END"
			]
		)
	
	for line in non_party_lines:
		var closest_party_spot = self.get_closest_to(used_spots, line[0].global_position)
		cutscene_lines.append_array(
			[
				"SEQUENTIAL",
				line[1],
				"LOOK_AT %s AT (%d, %d)" % [
					line[0].name, 
					int(round(closest_party_spot.global_position.x)), 
					int(round(closest_party_spot.global_position.y))
				],
				"END"
			]
		)
		
	cutscene_lines.append("END")
	
	await CutsceneService.play_custom_cutscene(cutscene_lines, {"pausable": false})
	
func get_closest_to(choices, current_position: Vector2):
	var current_choice = null
	var current_distance = INF
	for choice in choices:
		var distance = current_position.distance_squared_to(choice.global_position)
		if distance < current_distance:
			current_choice = choice
			current_distance = distance
	return current_choice
	
func fade_and_delete_mooks(battle_end_state):
	var cutscene_lines = [
		"FADE_OVERLAY MIX TO (0,0,0,1) IN 1",
		"SIMULTANEOUS",
	]
	
	for enemy_actor in battle_end_state.enemy_actors:
		cutscene_lines.append(
			"AWAIT %s die" % enemy_actor.name
		)
	cutscene_lines.append_array(["END", "FADE_OVERLAY MIX TO (0,0,0,0) IN 1"])
	
	await CutsceneService.play_custom_cutscene(cutscene_lines, {"pausable": false})
	

func tear_down_battle_positions(battle_end_state):
	var party: Party = EntitiesService.get_party()
	var proxy = EntitiesService.get_proxy()
	var cutscene_lines = []
	cutscene_lines.append("SIMULTANEOUS")
	cutscene_lines.append(
		"MOVE_CAMERA TO (%d, %d) IN 0.5" % [
			int(round(proxy.global_position.x)), 
			int(round(proxy.global_position.y))
		]
	)
	
	for party_actor in battle_end_state.party_actors:
		party_actor.on_battle_end()
		cutscene_lines.append(
			"RUN %s TO (%d, %d) AT 85" % [
				party_actor.name, 
				int(round(proxy.global_position.x)), 
				int(round(proxy.global_position.y))
			]
		)
	cutscene_lines.append("END")
	await CutsceneService.play_custom_cutscene(cutscene_lines, {"pausable": false})
	party.set_physics_process(true)
	party.on_proxy_enter(proxy)

func pause_non_participants(non_party_actors: Array):
	var world = EnvironmentService.get_world()
	var hidden_npcs = []

	for npc in world.get_tree().get_nodes_in_group("npc"):
		if npc not in non_party_actors and npc.visible:
			hidden_npcs.append(npc)
			npc.pause()
			npc.visible = false
	
	self.current_battle_parameters["hidden_npcs"] = hidden_npcs
	EntitiesService.get_proxy().set_mode(PlayerProxy.ProxyMode.NOT_THERE)

func resume_non_participants(end_proxy_mode):
	for npc in self.current_battle_parameters["hidden_npcs"]:
		npc.resume()
		npc.visible = true
	
	EntitiesService.get_proxy().set_mode(end_proxy_mode)
	
func try_escape() -> bool:
	var player_speeds = []
	var enemy_speeds = []
	
	for actor in self.loop.actors:
		if not actor.is_alive:
			continue
		if actor is PartyMember:
			player_speeds.append(actor.battler.stats.speed)
		else:
			enemy_speeds.append(actor.battler.stats.speed)

	player_speeds.sort()
	enemy_speeds.sort()
	
	var player_speed = 0
	var enemy_speed = 0
	for i in range(player_speeds.size()):
		player_speed += pow(0.6, i) * player_speeds[player_speeds.size() - 1 - i]
		
	for i in range(enemy_speeds.size()):
		enemy_speed += pow(0.6, i) * enemy_speeds[enemy_speeds.size() - 1 - i]
	
	var probability = 0.5 * (player_speed/enemy_speed) + 0.2 * self.current_battle_parameters["escape_tries"]
	
	self.current_battle_parameters["escape_tries"] += 1
	return randf() < probability
	
func mark_battle_as_escaped():
	assert(self.current_battle_parameters != null)
	self.loop.mark_battle_as_escaped()
	
func deal_rewards(rewards: BattleRewards):
	var party = EntitiesService.get_party()
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
		if !party_member.battler.is_alive:
			continue
			
		var previous_level = party_member.level	
		# TODO: include support party members
	
		party_member.experience += experience
		party_member.update_stats()
		
		if previous_level != party_member.level:
			await self.ui.prompt("%s leveled up!" % party_member.display_name)

func deal_items(party: Party, loot_bag: Dictionary):
	for loot in loot_bag:
		var item: InventoryItem = ItemService.id_to_item(loot)
		var amount = loot_bag[loot]
		await self.ui.prompt("Received %s!" % item.name)
		party.inventory.add(loot, amount)

func deal_money(_party: Party, money: int):
	await self.ui.prompt("Received %d G!" % money)
	# WIP
	# party.inventory.money

func revive_party_members(party: Party):
	for party_member in party.get_active_members():
		if not party_member.is_alive:
			party_member.battler.health = 1
	
	for party_member in party.get_inactive_members():
		if not party_member.is_alive:
			party_member.battler.health = 1

func add_rewards(rewards):
	self.loop.add_rewards(rewards)

func add_to_queue(actor):
	self.loop.add_to_queue(actor)
	
func remove_from_queue(actor):
	self.loop.remove_from_queue(actor)

func delay_actor(actor, delay):
	self.loop.delay_actor(actor, delay)

func prompt(text: String):
	await self.ui.prompt(text)
	
func announce(text: String, wait_time: float=0.0):
	self.ui.set_info_text(text)
	if wait_time > 0:
		await get_tree().create_timer(wait_time).timeout

func get_party_actors():
	return self.loop.actors.filter(func (it): return it is PartyMember)

func get_non_party_actors():
	return self.loop.actors.filter(func (it): return not it is PartyMember)

func observe_event(event: Event, observer):
	self.loop.observe_event(event, observer)

func stop_observe_event(event: Event, observer):
	self.loop.stop_observe_event(event, observer)

func notify_death(actor):
	if current_battle_parameters != null:
		self.loop.pending_deaths.push_back(actor)
