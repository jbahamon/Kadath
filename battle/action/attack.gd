extends BattleAction

func get_signature():
	return [
		{
			"name": "target",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ONE_ENEMY
		}
	]

func execute(actor, args: Dictionary):
	var target = args["target"]
	
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = actor.battler.get_physical_attack() * 5
	target.take_hit(hit)
	
	var prev_hp = target.battler.stats.health
	print("%s attacked %s (HP: %d -> HP: %d)" % [actor.display_name, target.display_name, prev_hp, target.battler.stats.health])
