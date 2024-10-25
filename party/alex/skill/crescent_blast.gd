extends "res://battle/action/aoe_on_target.gd"

@export var power: float
@export var aoe_power: float

func execute(actor):
	actor.battler.spend_energy(self.energy_cost)
	var targets = await self.area_of_effect.get_actors_at(self.target.global_position)
	
	var actor_party_member = actor is PartyMember
	
	var first_hit = Hit.new()
	first_hit.type = Hit.Element.METAL
	first_hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.power

	var hits = [
		func (): await self.target.take_hit(first_hit)
	]
	var additional_hits = targets.filter(
		func(aoe_target): return (aoe_target is PartyMember) != actor_party_member and aoe_target != self.target
	).map(
		func (aoe_target):
			var hit = Hit.new()
			hit.type = Hit.Element.METAL
			hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.aoe_power
			return func (): await aoe_target.take_hit(hit)
		
	)
	hits.append_array(additional_hits)
	
	await DoAll.new(hits).execute()
	
	self.reset()
	
