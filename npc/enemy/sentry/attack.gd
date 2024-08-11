extends "res://battle/action/simple_single_target.gd"

func execute(actor):
	var prev_hp = target.battler.stats.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor)
	
	actor.play_anim("attack")
	
	await get_tree().create_timer(1.2).timeout
	await self.target.take_hit(hit)
	
	print(
		"%s attacked %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.stats.health
		])
		
	actor.play_anim("idle")
	
	self.reset()
