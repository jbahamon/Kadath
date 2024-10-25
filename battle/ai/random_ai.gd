extends "./non_player_ai.gd"

class_name RandomAI


func choose_action(actor, _actors: Array):
	var options = actor.battler.get_action_options()
	while true:
		var action = options[0]
		if action is CompositeBattleOption:
			options = action.get_options().filter(
				func(option): return not option.is_disabled(actor)
			)
		else:
			return action
			

func fill_action_parameters(action: BattleAction, actor, actors: Array):
	var current_parameter_signature = action.get_next_parameter_signature()
	
	while current_parameter_signature != null:
		var new_parameter = self.get_action_parameter(
			actor, 
			action,
			actors, 
			current_parameter_signature
		)
	
		action.push_parameter(current_parameter_signature["name"], new_parameter)
			
		current_parameter_signature = action.get_next_parameter_signature()
	
	
func get_action_parameter(actor, action: BattleAction, actors: Array, argument_signature: Dictionary):
	match argument_signature["type"]:
		BattleAction.ActionArgument.TARGET:
			return action.get_targets(argument_signature["targeting_type"], actor, actors).pick_random()
		BattleAction.ActionArgument.ITEM:
			assert(false) #,"not yet implemented!")

