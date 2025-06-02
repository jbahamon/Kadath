extends BattleAction

var targets = null

func reset():
	self.targets = null
	
func highlight_option(_mode, _options):
	pass
	
func get_next_parameter_signature():
	if targets == null:
		return {
			"name": "targets",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ALL_ENEMIES,
			"prompt": "Win!",
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
	
	var hits = self.targets.map(func(target): return func(): await target.take_hit(actor, hit))
	await DoAll.new(hits).execute()
	self.reset()
