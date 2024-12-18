extends Reaction

func is_triggered_by(actor, hit, actors):
	return (
		not actor.battler.ai.second_phase and 
		actor.battler.health < floor(0.75 * actor.battler.stats.max_health)
	)

func execute(actor, actors):
	print("second phase...")
	actor.battler.ai.second_phase = true
	
