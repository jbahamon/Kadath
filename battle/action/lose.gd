extends BattleAction

var targets = null

func reset():
	self.targets = null
	
func get_next_parameter_signature():
	if targets == null:
		return {
			"name": "targets",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ALL_ENEMIES
		}
	else:
		return null
	
func push_parameter(parameter_name, value):
	assert(parameter_name == "targets", "unknown parameter %s passed to attack action" % parameter_name)
	self.targets = value
	
func pop_parameter() -> bool:
	var had_targets = self.target != null
	self.target = null
	return had_targets
	
func execute(actor):
	var hit = Hit.new()
	hit.type = Hit.Element.NONE
	hit.base_damage = INF
	
	for target in self.targets:
		var prev_hp = target.battler.stats.health
		target.take_hit(hit)
		print("%s attacked %s (HP: %d -> HP: %d)" % [actor.display_name, target.display_name, prev_hp, target.battler.stats.health])
	self.reset()
