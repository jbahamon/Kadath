extends "res://battle/action/simple_single_target.gd"

func get_next_parameter_signature():
	if target == null:
		return {
			"name": "target",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ONE_ENEMY,
			"prompt": "Choose a target",
		}
	else:
		return null


func execute(actor):
	var prev_hp = target.battler.stats.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor)
	await self.target.take_hit(hit)
	
	print(
		"%s attacked %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.stats.health
		])
		
	self.reset()
