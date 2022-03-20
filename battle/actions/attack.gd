extends BattleAction


func execute(actor: Battler, targets: Array):
	assert(len(targets) == 1)
	
	var target = targets[0]
	var prev_hp = target.stats.health
	var hit = Hit.new()
	hit.type = Hit.Element.NONE
	hit.base_damage = actor.get_physical_attack() * 5
	target.take_damage(hit)
	
	print("%s attacked %s (HP: %d -> HP: %d)" % [actor.display_name, target.display_name, prev_hp, target.stats.health])
