extends BattlerAI

signal turn_chosen

func get_turn(current_actors: Array) -> Turn:
	# self.interface.show_timeline()
	var battler = self.get_parent()
	var actor = battler.get_parent()
	var action = null
	var state = "waiting_for_action"
	self.interface.reset_options_stack()
	var options = battler.get_action_options()
	
	self.interface.current_actor = battler.get_parent()
	self.interface.set_options({
		"title": "What will %s do?" % battler.get_parent().display_name,
		"options": options
	})
	
	while true:
		match state:
			"waiting_for_action":
				action = await self.interface.option_selected
				if action != null:
					state = "waiting_for_parameters"
			"waiting_for_parameters":
				var parameters_ready = await self.wait_for_parameters(action, actor, current_actors)
				if not parameters_ready:
					state = "waiting_for_action"
				else:
					break

	var turn = Turn.new()
	turn.actor = actor
	turn.action = action
	self.interface.set_info_text(null)
	self.interface.hide_options()
	# self.interface.hide_timeline()

	return turn


func wait_for_parameters(action: BattleAction, action_actor, actors: Array):
	var current_parameter_signature = action.get_next_parameter_signature()
	
	while current_parameter_signature != null:
		var new_parameter = await self.interface.request_action_parameter(
			action,
			action_actor, 
			actors, 
			current_parameter_signature
		)
	
		if new_parameter == null:
			var was_popped = action.pop_parameter()
			if not was_popped:
				return false
		else:
			action.push_parameter(current_parameter_signature["name"], new_parameter)
			
		current_parameter_signature = action.get_next_parameter_signature()
	
	return true
