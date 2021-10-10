extends Node

# This class is responsible for running the battle's steps.
# It should handle choosing turn order, pre and post action events (such as 
# status damage, etc) and win/lose conditions
enum Event {
	TURN_START,
	TURN_END,
	BATTLE_END
}
enum Subscription {
	FIRE_ONCE,
	FIRE_ALWAYS
}

var battlers: Array
var preview_size: int = 6
var preview: Array
var turn_queue := TurnQueue.new()
var reset_preview := false
var ui: BattleUI
var event_subscribers: Dictionary = {} 

func initialize(init_battlers: Array, init_ui: BattleUI):
	self.battlers = init_battlers
	self.ui = init_ui
	
	preview = []
	turn_queue.reset()
	
	for battler in battlers:
		battler.initialize(init_ui)
		turn_queue.add(battler)
	
	self.event_subscribers.clear()
	
	for event in Event.values():
		event_subscribers[event] = {}
	
	self.preview = turn_queue.get_preview(self.preview_size)

func do_battle():
	var current_battlers: Array
	var turns: Array
	while true:
		print(get_preview_text())
		
		# get the chunk of characters on the same team 
		# do their turns together
		current_battlers = self.turn_queue.get_current_battlers()
		
		turns = []
		
		for battler in current_battlers:
			var turn = battler.ai.get_turn(battlers)
			if turn is GDScriptFunctionState:
				turn = yield(turn, "completed")
			
			turns.append(turn)
	
		for turn in turns:
			print("%s used %s!" % [turn.actor.name, turn.action.name])
			var r = turn.play()
			if r is GDScriptFunctionState:
				r = yield(r, "completed")
				
			self.notify_subscribers(Event.TURN_END, "on_turn_end")
			
			if is_battle_won():
				print("You won!")
				return

			if is_battle_lost():
				print("You lost...")
				return
				

			preview = preview.slice(current_battlers.size(), preview.size() - 1)
			
		self.preview = self.turn_queue.get_preview(self.preview_size)
	
func is_battle_won() -> bool:
	for battler in battlers:
		if not battler.is_party_member:
			return false
	return true
	
func is_battle_lost() -> bool:
	for battler in battlers:
		if battler.is_alive() and battler.is_party_member:
			return false
	return true

func remove_battler(battler: Battler):
	for event in self.event_subscribers:
		event_subscribers[event].erase(battler)
	
	if not battler.is_party_member:	
		self.battlers.erase(battler)
		
	self.turn_queue.erase(battler)
	
	while true:
		var idx = self.preview.find(battler)
		if idx >= 0:
			self.preview.remove(idx)
		else:
			break
	
func get_preview_text():
	var r = "Turn Preview: "
	for b in preview:
		r += b.display_name + " "
	
	return r

func subscribe_to_event(subscriber, event, subscription_type):
	self.event_subscribers[event][subscriber] = subscription_type
	
func notify_subscribers(event: int, method: String):
	var to_be_removed = []
	for subscriber in event_subscribers[event]:
		var subscription_type = event_subscribers[event][subscriber]
		subscriber.call(method)
		if subscription_type == Subscription.FIRE_ONCE:
			to_be_removed.append(subscriber)
	for subscriber in to_be_removed:
		event_subscribers[event].erase(subscriber)
