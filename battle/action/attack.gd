extends BattleAction

var target = null

func reset():
	self.target = null
	
func get_next_parameter_signature():
	if target == null:
		return {
			"name": "target",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ONE_ENEMY
		}
	else:
		return null
	
func push_parameter(parameter_name, value):
	assert(parameter_name == "target", "unknown parameter %s passed to attack action" % parameter_name)
	self.target = value
	
func pop_parameter() -> bool:
	var was_target_present = self.target != null
	self.target = null
	return was_target_present
	
func execute(actor):
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = actor.battler.get_physical_attack() * 5
	self.target.take_hit(hit)
	
	var prev_hp = target.battler.stats.health
	print("%s attacked %s (HP: %d -> HP: %d)" % [actor.display_name, self.target.display_name, prev_hp, self.target.battler.stats.health])
	self.reset()
