extends "res://battle/action/simple_single_target.gd"

@export var normal_attack_factor = 0.5
@export var heal_factor = 0.75
@export var energy_gain_factor = 0.1

func execute(actor):
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor) * self.normal_attack_factor
	
	await self.target.take_hit(hit)
	
	# For balance, we could make it so it heals less with each use. 
	# Like 0.8^n_usages and start from a big one.
	await actor.heal(ceil(self.heal_factor * hit.effective_damage))
	
	self.reset()
