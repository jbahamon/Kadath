extends Reaction

var actor_to_attack

func is_triggered_by(_actor, hit: Hit, _actors):
	return hit.base_damage > 0

func check(actor, hit_from, hit, actors):
	if self.is_triggered_by(actor, hit, actors):
		self.actor_to_attack = hit_from
		actor.battler.pending_reaction = self
		actor.battler.ai.remove_reaction(self)
		return true
	else:
		return false
		
func execute(actor, _actors):
	var beam = actor.get_node("Battler/Actions/Beam")
	beam.target = self.actor_to_attack
	await beam.execute(actor) 
	
