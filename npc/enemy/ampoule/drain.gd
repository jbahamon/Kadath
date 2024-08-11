extends "res://battle/action/simple_single_target.gd"

@export var normal_attack_factor = 0.75
@export var heal_factor = 1

func execute(actor):
	var prev_hp = target.battler.stats.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor) * self.normal_attack_factor
	
	var damage = await self.target.take_hit(hit)
	await actor.heal(ceil(self.heal_factor * damage))
	
	print(
		"%s drained %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.stats.health
		])
		
	
	self.reset()
