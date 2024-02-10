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
	assert(parameter_name == "targets", "unknown parameter %s passed to win action" % parameter_name)
	self.targets = value.targets
	
func pop_parameter() -> bool:
	var had_targets = self.targets != null
	self.targets = null
	return had_targets
	
func execute(actor):
	var hit = Hit.new()
	hit.type = Hit.Element.NONE
	hit.base_damage = INF
	
	var hits = []
	for target in self.targets:
		var prev_hp = target.battler.stats.health
		hits.append(
			func (): await target.take_hit(hit)
		)
		print("%s attacked %s (HP: %d -> HP: %d)" % [actor.display_name, target.display_name, prev_hp, target.battler.stats.health])
	
	await DoAll.new(hits).execute()
	self.reset()
