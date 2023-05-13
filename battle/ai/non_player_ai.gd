extends BattlerAI

func get_turn(actors: Array) -> Turn:
	# Select an action to perform in combat
	# Can be based on state of the actor
	var actor = get_parent().get_parent()
	
	var action = self.choose_action(actor, actors)
	
	var turn = Turn.new()
	turn.actor = actor
	turn.action = action
	turn.action_args = self.choose_action_args(action.get_signature(), actor, actors)
	return turn
		
func choose_action(_actor, _actors: Array) -> BattleAction:
	# Select an action + targets to perform in combat
	# Can be based on state of the actor
	assert(false,"%s missing override of the choose_action method" % name)
	return null

func choose_action_args(_action_signature: Array, _actor, _actors: Array) -> Dictionary:
	assert(false,"%s missing override of the choose_action method" % name)
	return {}
