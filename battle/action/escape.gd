extends BattleAction

func reset():
	pass
	
func get_next_parameter_signature():
	return null
	
func push_parameter(_parameter_name, _value):
	pass
	
func pop_parameter():
	return null
	
func execute(_actor):
	var party_actors = BattleService.get_party_actors()
	for actor in party_actors:
		if actor.is_alive:
			actor.set_orientation(-actor.current_orientation)
			actor.play_anim("run")
	if false:
		await BattleService.prompt("Fled the battle!")
		BattleService.mark_battle_as_escaped()
	else:
		await BattleService.prompt("Tried to escape, but failed...")
		BattleService.announce("")
		for actor in party_actors:
			if actor.is_alive:
				actor.set_orientation(-actor.current_orientation)
				actor.play_anim("battle_idle")
	
