extends BattlerAI

func get_turn(actors: Array) -> Turn:
	# Select an action to perform in combat
	# Can be based on state of the actor
	var actor = get_parent().get_parent()
	
	var action = self.choose_action(actor, actors)
	self.fill_action_parameters(action, actor, actors)
	
	var turn = Turn.new()
	turn.actor = actor
	turn.action = action
	
	return turn
		
func choose_action(_actor, _actors: Array) -> BattleAction:
	# Select an action + targets to perform in combat
	# Can be based on state of the actor
	assert(false,"%s missing override of the choose_action method" % name)
	return null

func fill_action_parameters(_action: BattleAction, _actor, _actors: Array):
	assert(false,"%s missing override of the fill_action_parameters method" % name)
	return {}
