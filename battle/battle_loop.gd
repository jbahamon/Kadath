const BattleEndState = preload("res://battle/battle_end_state.gd")

# This class is responsible for running the battle's steps.
# It should handle choosing turn order, pre and post action events (such as 
# status damage, etc) and win/lose conditions

var actors: Array
var preview_size: int = 5
var turn_queue := TurnQueue.new()
var pending_deaths = []

var ui: BattleUI
var battle_end_state 

var observers = {}

func initialize(init_actors: Array, init_ui: BattleUI):
	self.actors = init_actors
	self.ui = init_ui
	turn_queue.reset()
	
	for actor in actors:
		actor.battler.initialize(init_ui)
		turn_queue.add(actor, true)

	for event in BattleService.Event.values():
		observers[event] = []
		
func do_battle():
	battle_end_state = BattleEndState.new()
	
	while true:
		var current_actor = self.turn_queue.get_current_actor()
		for observer in self.observers[BattleService.Event.TURN_START]:
			await observer.on_turn_start(current_actor)
			
		self.update_preview(current_actor)
		var turn = await current_actor.battler.ai.get_turn(self.actors)
		
		EntitiesService.battle_turn_indicator.visible = false
		
		# Small pause for usabilty/not making it feel like it's too fast
		await ui.get_tree().create_timer(0.2).timeout
		await turn.play()
		
		await self.check_deaths_and_reactions()
		await self.check_breakdowns()
		
		for observer in self.observers[BattleService.Event.TURN_END]:
			await observer.on_turn_end(current_actor)
			
		if is_battle_won():
			var party_actors = actors.filter(func(actor): return actor is PartyMember)
			self.battle_end_state.party_actors = party_actors
			self.battle_end_state.result = BattleEndState.Result.WIN
			break
			
		elif is_battle_lost():
			self.battle_end_state.result = BattleEndState.Result.LOSE
			break
			
		elif self.battle_end_state.result == BattleEndState.Result.ESCAPE:
			self.battle_end_state.party_actors = []
			self.battle_end_state.enemy_actors = []
			
			for actor in actors:
				if not actor is PartyMember:
					self.battle_end_state.enemy_actors.append(actor)
				else:
					self.battle_end_state.party_actors.append(actor)
			break
		else:
			var party_members = self.actors.filter(func (it): return it.is_alive and it is PartyMember)
			var enemies = self.actors.filter(func (it): return it.is_alive and it is not PartyMember)
			for actor in self.actors.filter(func (it): return it.is_alive):
				var opponents = enemies if actor is PartyMember else party_members
				var target = BattleService.get_closest_to(opponents, actor.global_position)
				actor.set_orientation(actor.global_position.direction_to(target.global_position))

	self.turn_queue.reset()
	
	for key in self.observers:
		self.observers[key] = []
		
	return self.battle_end_state

func add_to_queue(actor):
	self.turn_queue.add(actor)
	
func remove_from_queue(actor):
	self.turn_queue.erase(actor)
	
func observe_event(event: BattleService.Event, observer):
	assert(observer not in self.observers[event])
	self.observers[event].append(observer)
	
func stop_observe_event(event: BattleService.Event, observer):
	self.observers[event].erase(observer)

func is_battle_won() -> bool:
	if self.battle_end_state.result == BattleEndState.Result.WIN:
		return true
		
	return actors.all(func(actor): return actor is PartyMember)
	
func is_battle_lost() -> bool:
	if self.battle_end_state.result == BattleEndState.Result.LOSE:
		return true
	
	return not actors.any(func (actor): return actor.battler.is_alive and actor is PartyMember)
	
func mark_battle_as_escaped():
	self.battle_end_state.result = BattleEndState.Result.ESCAPE
	
func on_actor_death(actor):
	# No revival should happen here
	for observer in self.observers[BattleService.Event.BEFORE_ACTOR_DEATH]:
		await observer.before_actor_death(actor)
		
	if actor is PartyMember:
		actor.play_anim("downed")
		actor.battler.status_effects.add(DownedStatus.new())
	else:
		self.add_rewards(actor.battler.rewards)
		self.actors.erase(actor)
		await actor.die(CutsceneInstruction.ExecutionMode.PLAY)
		self.remove_from_queue(actor)
	
	# Any revivals should happen here
	for observer in self.observers[BattleService.Event.BEFORE_ACTOR_DEATH]:
		await observer.after_actor_death(actor)
	
	# self.update_preview()
	
func add_rewards(rewards: BattleRewards):
	self.battle_end_state.add_rewards(rewards)
		
func update_preview(current_actor):
	var preview = self.turn_queue.get_preview(self.preview_size)
	self.ui.update_preview(current_actor, preview)

func delay_actor(actor, delay):
	self.turn_queue.add_charge(actor, delay)

func check_deaths_and_reactions():
	var should_continue = true
	while should_continue:
		should_continue = false
		# First, deaths
		while true: 
			var actor = self.pending_deaths.pop_back()
			if actor == null:
				break
			should_continue = true
			await self.on_actor_death(actor)
			
		# Then reactions
		for actor in actors:
			if actor.battler.pending_reaction != null and actor.battler.is_alive:
				should_continue = true
				await actor.battler.pending_reaction.execute(actor, actors)
				actor.battler.pending_reaction = null

func check_breakdowns():

	for actor in actors:
		if (
			actor is PartyMember and 
			actor.is_alive and 
			actor.energy <= 0 and 
			not actor.battler.status_effects.has("breakdown")
		):
			await actor.battler.status_effects.add(actor.breakdown_status.new())
