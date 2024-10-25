extends "res://battle/ai/non_player_ai.gd"

var attack
var consume

func _ready() -> void:
	var parent: Node = self.get_parent()
	self.attack = parent.get_node("Actions/Attack")
	self.consume = parent.get_node("Actions/Consume")

func choose_action(actor, actors: Array):
	if actor.health < floor(actor.max_health/2) and actor.get_allies(actors).size() > 1:
		return self.attack if (randi() % 100) > 80 else self.consume
	else:
		return self.attack

func fill_action_parameters(action: BattleAction, actor, actors: Array):
	action.target = actor.get_enemies(actors).pick_random()
	
	if action == self.consume:
		var allies = actor.get_allies(actors)
			
		var min_dist = INF
		var sacrifice = null
		for ally in allies:
			if ally == actor:
				continue
			var dist = actor.global_position.distance_squared_to(ally.global_position)
			if dist < min_dist:
				min_dist = dist
				sacrifice = ally
		
		action.allies = allies.filter(func(ally): return ally != sacrifice)
		action.sacrifice = sacrifice
