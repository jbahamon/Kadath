extends Node

var BattleEndState = preload("res://battle/battle_end_state.gd")

# This class is responsible for running the battle's steps.
# It should handle choosing turn order, pre and post action events (such as 
# status damage, etc) and win/lose conditions

var actors: Array
var preview_size: int = 6
var preview: Array
var turn_queue := TurnQueue.new()
var reset_preview := false
var ui: BattleUI
var event_subscribers: Array
var battle_end_state

func initialize(init_actors: Array, init_ui: BattleUI):
	self.actors = init_actors
	self.ui = init_ui
	
	preview = []
	turn_queue.reset()
	
	for actor in actors:
		actor.battler.initialize(init_ui)
		turn_queue.add(actor)
	
	self.event_subscribers = [] 
	for event_type in BattleService.Event:
		self.event_subscribers.append({})
	

func do_battle():
	
	battle_end_state = BattleEndState.new()
	
	while true:
		
		self.update_preview()
		
		var current_actor = self.turn_queue.get_current_actor()
		var turn = await current_actor.battler.ai.get_turn(self.actors)

		print("%s used %s!" % [turn.actor.name, turn.action.name])
		await turn.play()
		self.notify_subscribers(BattleService.Event.TURN_END, "on_turn_end")
		
		if is_battle_won():
			self.ui.hide_timeline()
			var party_actors = []
			for actor in actors:
				if actor is PartyMember:
					party_actors.append(actor)
			battle_end_state.set_active_party_actors(party_actors)
			battle_end_state.player_won = true
			return battle_end_state

		if is_battle_lost():
			battle_end_state.player_won = false
			return battle_end_state

	
	return false
	
func is_battle_won() -> bool:
	for actor in actors:
		if not actor is PartyMember:
			return false
	return true
	
func is_battle_lost() -> bool:
	for actor in actors:
		if actor.battler.is_alive() and actor is PartyMember:
			return false
	return true

func remove_actor(actor):
	for subscribers in self.event_subscribers:
		subscribers.erase(actor)
	
	if not actor is PartyMember:
		self.actors.erase(actor)
		
	self.turn_queue.erase(actor)
	self.update_preview()
	
func add_rewards(rewards: BattleRewards):
	self.battle_end_state.add_rewards(rewards)

func subscribe_to_event(subscriber, event, subscription_type):
	self.event_subscribers[event][subscriber] = subscription_type
	
func notify_subscribers(event: int, method: String):
	var to_be_removed = []
	for subscriber in self.event_subscribers[event]:
		var subscription_type = self.event_subscribers[event][subscriber]
		await subscriber.call(method)
		
		if subscription_type == BattleService.Subscription.FIRE_ONCE:
			to_be_removed.append(subscriber)
	for subscriber in to_be_removed:
		event_subscribers[event].erase(subscriber)
		
func update_preview():
	self.preview = self.turn_queue.get_preview(self.preview_size)
	self.ui.update_preview(self.preview)
	

