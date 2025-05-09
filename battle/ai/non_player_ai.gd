extends BattlerAI

func get_turn(actors: Array) -> Turn:
	# Select an action to perform in combat
	# Can be based on state of the actor
	var actor = get_parent().get_parent()
	
	await get_tree().create_timer(0.5).timeout
	var action = await self.choose_action(actor, actors)
	
	self.fill_action_parameters(action, actor, actors)
	
	var turn = Turn.new()
	turn.actor = actor
	turn.action = action
	
	return turn
		
func choose_action(_actor, _actors: Array) -> BattleAction:
	# Select an action + targets to perform in combat
	# Can be based on state of the actor
	assert(false,"%s missing override of the choose_action method" % name)
	# Unreachable, but silences a warning for this not being async.
	await get_tree().create_timer(0.0).timeout
	return null

func fill_action_parameters(_action: BattleAction, _actor, _actors: Array):
	assert(false,"%s missing override of the fill_action_parameters method" % name)
	return {}
