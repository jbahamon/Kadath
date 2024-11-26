const BattleEndState = preload("res://battle/battle_end_state.gd")

# This class is responsible for running the battle's steps.
# It should handle choosing turn order, pre and post action events (such as 
# status damage, etc) and win/lose conditions

var actors: Array
var preview_size: int = 6
var preview: Array
var turn_queue := TurnQueue.new()
var reset_preview := false
var ui: BattleUI
var battle_end_state 

func initialize(init_actors: Array, init_ui: BattleUI):
	self.actors = init_actors
	self.ui = init_ui
	
	preview = []
	turn_queue.reset()
	
	for actor in actors:
		actor.battler.initialize(init_ui)
		turn_queue.add(actor)

func do_battle():
	battle_end_state = BattleEndState.new()
	
	while true:
		self.update_preview()
		var current_actor = self.turn_queue.get_current_actor()
		var turn = await current_actor.battler.ai.get_turn(self.actors)

		await turn.play()
		
		var dead_actors = actors.filter(
			func(actor): 
				return (not actor.battler.is_alive and 
						not (actor is PartyMember and actor.battler.status_effects.has("downed")))
		)
		
		for actor in dead_actors:
			await self.on_actor_death(actor)
		
		for actor in actors:
			if actor.battler.pending_reaction != null and actor.battler.is_alive:
				await actor.battler.pending_reaction.execute()
				actor.battler.pending_reaction = null
		
		self.ui.update_player_state()
		if is_battle_won():
			self.ui.hide_timeline()
			var party_actors = actors.filter(func(actor): return actor is PartyMember)
			self.battle_end_state.party_actors = party_actors
			self.battle_end_state.result = BattleEndState.Result.WIN
			break
			
		elif is_battle_lost():
			self.battle_end_state.result = BattleEndState.Result.LOSE
			break
			
		elif self.battle_end_state.result == BattleEndState.Result.ESCAPE:
			self.ui.hide_timeline()
			self.battle_end_state.party_actors = []
			self.battle_end_state.enemy_actors = []
			
			for actor in actors:
				if not actor is PartyMember:
					self.battle_end_state.enemy_actors.append(actor)
				else:
					self.battle_end_state.party_actors.append(actor)
			break
			
	self.turn_queue.reset()
	return self.battle_end_state

func add_to_queue(actor):
	self.turn_queue.add(actor)
	
func remove_from_queue(actor):
	self.turn_queue.erase(actor)
	
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
	if actor is PartyMember:
		actor.play_anim("downed")
		actor.battler.status_effects.add(DownedStatus.new())
	else:
		self.add_rewards(actor.battler.rewards)
		self.actors.erase(actor)
		await actor.die(CutsceneInstruction.ExecutionMode.PLAY)
		self.remove_from_queue(actor)
	self.update_preview()
	
func add_rewards(rewards: BattleRewards):
	self.battle_end_state.add_rewards(rewards)
		
func update_preview():
	self.preview = self.turn_queue.get_preview(self.preview_size)
	self.ui.update_preview(self.preview)

func delay_actor(actor, delay):
	self.turn_queue.add_charge(actor, delay)
