extends Reaction

func is_triggered_by(actor, _hit, _actors):
	return (
		not actor.battler.ai.second_phase and 
		actor.battler.health < floor(0.75 * actor.battler.stats.max_health)
	)

func execute(actor, _actors):
	actor.battler.ai.second_phase = true
	actor.battler.ai.remove_reaction(self)
	actor.play_anim("RESET")
