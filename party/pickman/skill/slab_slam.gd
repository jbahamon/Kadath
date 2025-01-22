extends "res://battle/action/line_to_target.gd"

@export var power: float
@export var line_power: float

func execute(actor):
	actor.battler.spend_energy(self.energy_cost)
	var targets = await self.line_of_effect.get_actors_in_line(actor.global_position, self.target.global_position)
	
	var actor_party_member = actor is PartyMember
	
	var first_hit = Hit.new()
	first_hit.type = Hit.Element.METAL
	first_hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.power

	var hits = [
		func (): await self.target.take_hit(actor, first_hit)
	]
	
	var additional_hits = targets.filter(
		func(line_target): return (line_target is PartyMember) != actor_party_member and line_target != self.target
	).map(
		func (line_target):
			var hit = Hit.new()
			hit.type = Hit.Element.ABYSS
			hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.line_power
			return func (): await line_target.take_hit(actor, hit)
	)
	hits.append_array(additional_hits)
	
	await DoAll.new(hits).execute()
	
	self.reset()
	
