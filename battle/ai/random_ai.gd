extends "./non_player_ai.gd"

class_name RandomAI


func choose_action(actor, _actors: Array):
	return actor.battler.get_actions()[0]

func choose_action_args(action_signature: Array, actor, actors) -> Dictionary:
	var args = {}
	
	for action_arg in action_signature:
		var arg_name = action_arg["name"]
		
		match action_arg["type"]:
			BattleAction.ActionArgument.TARGET:
				args[arg_name] = self.choose_targets(action_arg["targeting_type"], actor, actors)
	
	return args
	
func choose_targets(targeting_type, actor, actors):
	# Chooses a target to perform an action on
	match targeting_type:
		BattleAction.TargetType.ALL_ALLIES:
			return actor.get_allies(actors)
		BattleAction.TargetType.ONE_ALLY:
			var allies = actor.get_allies(actors)
			return [allies[randi() % allies.size()]]
		BattleAction.TargetType.ALL_ENEMIES:
			return actor.get_enemies(actors)
		BattleAction.TargetType.ONE_ENEMY:
			var enemies = actor.get_enemies(actors)
			return [enemies[randi() % enemies.size()]]
		BattleAction.TargetType.SELF:
			return [actor]
		_:
			return []

