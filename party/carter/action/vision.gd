extends "res://battle/action/simple_single_target.gd"

var scanned_enemies = {}

func execute(actor):
	var enemy_id = self.target.enemy_id
	
	# Unlock 
	if enemy_id in self.unlocking_ids:
		actor.unlock_skill(self.unlocking_ids[enemy_id])

	self.reset()
