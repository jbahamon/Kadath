extends "res://battle/ai/non_player_ai.gd"

var Change = preload("res://npc/enemy/thymiaterion/reaction/change.gd")
var jump
var shoot
var whip
var prepare_chew
var chew
var beam
var counter

var turn_counter = 0
var second_phase = false

func _ready() -> void:
	var parent: Node = self.get_parent()
	self.jump = parent.get_node("Actions/Jump")
	self.shoot = parent.get_node("Actions/Shoot")
	self.whip = parent.get_node("Actions/Whip")
	self.chew = parent.get_node("Actions/Chew")
	self.counter = parent.get_node("Actions/PrepareBeamCounter")
	self.prepare_chew = parent.get_node("Actions/PrepareChew")
	self.reactions = [Change.new()]

func choose_action(_actor, _actors: Array):
	if not second_phase:
		
		match turn_counter:
			0, 1: 
				turn_counter += 1
				return self.shoot
			2: 
				turn_counter = 0
				return self.jump
			_:
				return self.shoot
	else:
		match turn_counter:
			0, 1:
				turn_counter += 1
				return self.whip
			2:
				turn_counter += 1
				return self.whip
			3, 4: 
				turn_counter += 1
				return self.whip
			5:
				turn_counter = 0
				return self.whip

func fill_action_parameters(action: BattleAction, actor, actors: Array):
	if action == self.jump or action == beam:
		action.targets = actor.get_enemies(actors)
	elif action == self.shoot or action == self.whip:
		action.target = actor.get_enemies(actors).pick_random()
	elif action == self.chew:
		var enemies = actor.get_enemies(actors)
		var min_hp = INF
		var target = null
		for enemy in enemies:
			if enemy.health < min_hp:
				min_hp = enemy.health 
				target = enemy
		action.target = target
