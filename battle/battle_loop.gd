extends Node

class_name BattleLoop
# This class is responsible for running the battle's steps.
# It should handle choosing turn order, pre and post action events (such as 
# status damage, etc) and win/lose conditions

var battlers: Array
var preview_size: int = 6
var preview: Array
var priority_queue := PriorityQueue.new()
var reset_preview := false


func initialize(init_battlers: Array):
	self.battlers = init_battlers
	for battler in battlers:
		priority_queue.add(battler, battler.get_priority())
	
	# We build the preview. We have to advance the queue to get the preview
	for i in range(preview_size):
		var preview_battler = priority_queue.pop_min()
		preview.append(preview_battler)
		priority_queue.add(preview_battler, preview_battler.get_priority())
		
	

func do_battle():
	var current_battler: Battler
	var action
	var targets: Array


	while true:
		print(get_preview_text())
		current_battler = self.preview.pop_front()
		print("%s's turn" % current_battler.display_name)
		
		action = yield(current_battler.choose_action(current_battler, battlers), "completed")
		targets = yield(current_battler.choose_targets(current_battler, action, battlers), "completed")
	
		print("%s used %s" % [current_battler.display_name, action.name])
	
		yield(self.play_turn(action, targets), "completed")
		
		if is_battle_won():
			print("You won!")
			break

		if is_battle_lost():
			print("You lost...")
			break
					
		self.update_queue()

	
func is_battle_won() -> bool:
	for battler in battlers:
		if battler.alive and not battler.is_ally():
			return false
	return true
	
	
func is_battle_lost() -> bool:
	for battler in battlers:
		if battler.alive and battler.is_party_member():
			return false
	return true
	

func update_queue():
	if self.reset_preview:
		preview = []
		self.reset_preview = false
		
	while preview.size() < preview_size:
		var preview_battler = priority_queue.pop_min()
		preview.push_back(preview_battler)
		priority_queue.add(preview_battler, preview_battler.get_priority())
	
func get_preview_text():
	var r = "Turn Preview: "
	for b in preview:
		r += b.display_name
	
	return r

func play_turn(action, targets: Array):
	yield(action.execute(targets), "completed")

