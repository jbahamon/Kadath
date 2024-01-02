extends "./non_player_ai.gd"

class_name RandomAI


func choose_action(actor, _actors: Array):
	var options = actor.battler.get_action_options()
	while true:
		var action = options[0]
		if action is CompositeBattleOption:
			var available_options = action.get_options()
			options = []
			for option in available_options:
				if not option.is_disabled():
					options.append(option)
		else:
			return action
			

func fill_action_parameters(action: BattleAction, actor, actors: Array):
	var current_parameter_signature = action.get_next_parameter_signature()
	
	while current_parameter_signature != null:
		var new_parameter = self.get_action_parameter(
			actor, 
			actors, 
			current_parameter_signature
		)
	
		action.push_parameter(current_parameter_signature["name"], new_parameter)
			
		current_parameter_signature = action.get_next_parameter_signature()
	
	
func get_action_parameter(actor, actors: Array, argument_signature: Dictionary):
	match argument_signature["type"]:
		BattleAction.ActionArgument.TARGET:
			return self.choose_targets(actor, actors, argument_signature["targeting_type"])
		BattleAction.ActionArgument.ITEM:
			assert(false) #,"not yet implemented!")

func choose_targets(actor, actors: Array, targeting_type: int):
	match targeting_type: 
		BattleAction.TargetType.ONE_ENEMY:
			return actor.get_enemies(actors)[0]
		BattleAction.TargetType.ONE_ALLY:
			return actor.get_allies(actors)[0]
		BattleAction.TargetType.ALL_ENEMIES:
			return actor.get_enemies(actors)
		BattleAction.TargetType.ALL_ALLIES:
			return actor.get_allies(actors)
		BattleAction.TargetType.SELF:
			return actor

