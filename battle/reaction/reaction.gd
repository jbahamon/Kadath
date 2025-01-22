class_name Reaction

func check(actor, _hit_from, hit, actors):
	if self.is_triggered_by(actor, hit, actors):
		actor.battler.pending_reaction = self
		return true
	else:
		return false

func is_triggered_by(_actor, _hit: Hit, _actors: Array) -> bool:
	assert(false, "missing override of is_triggered_by method")
	return false
	
func execute(_actor, _oactors):
	assert(false, "missing override of execute method")
