const BattleEndState = preload("res://battle/battle_end_state.gd")

signal actor_dead(actor)
signal turn_start(turn)
signal turn_end(turn)

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
		self.connect_actor(actor)

func do_battle():
	battle_end_state = BattleEndState.new()
	
	while true:
		
		self.update_preview()
		
		var current_actor = self.turn_queue.get_current_actor()
		var turn = await current_actor.battler.ai.get_turn(self.actors)

		emit_signal("turn_start", turn)
		await turn.play()
		emit_signal("turn_end", turn)
		self.ui.update_player_state()
		if is_battle_won():
			self.ui.hide_timeline()
			var party_actors = []
			for actor in actors:
				self.disconnect_actor(actor)
				if actor is PartyMember:
					party_actors.append(actor)
			self.battle_end_state.party_actors = party_actors
			self.battle_end_state.result = BattleEndState.Result.WIN
			return self.battle_end_state
			
		elif is_battle_lost():
			for actor in actors:
				self.disconnect_actor(actor)
			self.battle_end_state.result = BattleEndState.Result.LOSE
			return battle_end_state
			
		elif self.battle_end_state.result == BattleEndState.Result.ESCAPE:
			self.ui.hide_timeline()
			self.battle_end_state.party_actors = []
			self.battle_end_state.enemy_actors = []
			
			for actor in actors:
				if not actor is PartyMember:
					self.battle_end_state.enemy_actors.append(actor)
				else:
					self.battle_end_state.party_actors.append(actor)
			
			return self.battle_end_state
		
	return false
	
func is_battle_won() -> bool:
	if self.battle_end_state.result == BattleEndState.Result.WIN:
		return true
		
	for actor in actors:
		if not actor is PartyMember:
			return false
	return true
	
func is_battle_lost() -> bool:
	if self.battle_end_state.result == BattleEndState.Result.LOSE:
		return true
	
	for actor in actors:
		if actor.battler.is_alive and actor is PartyMember:
			return false
	return true

func mark_battle_as_escaped():
	self.battle_end_state.result = BattleEndState.Result.ESCAPE
	
func on_actor_death(actor):
	# One last chance for revival (e.g. auto revive skills, etc)
	emit_signal("actor_dead", actor)
	
	if actor.battler.is_alive:
		return

	if actor is PartyMember:
		actor.battler.status_effects.add(DownedStatus.new())
	else:
		self.add_rewards(actor.battler.rewards)
		self.actors.erase(actor)
		await actor.die()
		
	self.turn_queue.erase(actor)
	self.update_preview()
	
func add_rewards(rewards: BattleRewards):
	self.battle_end_state.add_rewards(rewards)
		
func update_preview():
	self.preview = self.turn_queue.get_preview(self.preview_size)
	self.ui.update_preview(self.preview)
	
func connect_actor(actor):
	actor.battler.died.connect(self.on_actor_death)
	var status_effects = actor.battler.status_effects
	self.turn_start.connect(status_effects.on_turn_start)
	self.turn_end.connect(status_effects.on_turn_end)
	self.actor_dead.connect(status_effects.on_actor_dead)

func disconnect_actor(actor):
	actor.battler.died.disconnect(self.on_actor_death)
	var status_effects = actor.battler.status_effects
	self.turn_start.disconnect(status_effects.on_turn_start)
	self.turn_end.disconnect(status_effects.on_turn_end)
	self.actor_dead.disconnect(status_effects.on_actor_dead)

