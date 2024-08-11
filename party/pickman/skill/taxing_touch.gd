extends "res://battle/action/simple_single_target.gd"

@export var damage_factor = 1.25
@export var delay = 100
	
func execute(actor):
	actor.battler.stats.spend_energy(self.energy_cost)
	var prev_hp = target.battler.stats.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor) * self.damage_factor
	await self.target.take_hit(hit)
	
	BattleService.delay_actor(target, self.delay)
	
	print(
		"%s attacked %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.stats.health
		])
	self.reset()
	
