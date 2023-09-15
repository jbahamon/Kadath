extends "res://battle/action/attack.gd"

func execute(actor):
	var target = self.args["target"]
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = actor.battler.get_physical_attack() * 12
	self.target.take_hit(hit)
	
	var prev_hp = target.battler.stats.health
	print(
		"%s attacked %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.stats.health
		])
	self.reset()
