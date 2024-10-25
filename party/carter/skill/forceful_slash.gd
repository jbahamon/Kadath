extends "res://battle/action/simple_single_target.gd"

@export var damage_factor: float = 3

func execute(actor):
	actor.battler.spend_energy(self.energy_cost)
	var prev_hp = target.battler.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor) * self.damage_factor
	await self.target.take_hit(hit)
	
	print(
		"%s attacked %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.health
		])
	self.reset()
	
