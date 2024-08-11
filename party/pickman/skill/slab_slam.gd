extends "res://battle/action/line_to_target.gd"

@export var power: float
@export var line_power: float

func execute(actor):
	actor.battler.stats.spend_energy(self.energy_cost)
	var targets = await self.line_of_effect.get_actors_in_line(actor.global_position, self.target.global_position)
	
	var actor_party_member = actor is PartyMember
	
	var first_hit = Hit.new()
	first_hit.type = Hit.Element.METAL
	first_hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.power

	var hits = [
		func (): await self.target.take_hit(first_hit)
	]
	for line_target in targets:
		if (line_target is PartyMember) != actor_party_member and line_target != self.target:
			var hit = Hit.new()
			hit.type = Hit.Element.METAL
			hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.line_power
			hits.append(
				func (): await line_target.take_hit(hit)
			)
	
	await DoAll.new(hits).execute()
	
	self.reset()
	
