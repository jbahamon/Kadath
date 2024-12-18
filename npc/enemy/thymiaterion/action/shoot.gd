extends "res://battle/action/simple_single_target.gd"

func execute(actor):
	var prev_hp = target.battler.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor)
	await self.target.take_hit(hit)
	
	print(
		"%s used Shot on %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.health
		])
		
	self.reset()
