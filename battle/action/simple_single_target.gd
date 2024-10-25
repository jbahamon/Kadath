extends BattleAction

var target = null

var currently_highlighted_target = null
var stored_material = null

func reset():
	self.target = null
	
func get_next_parameter_signature():
	if target == null:
		return {
			"name": "target",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ONE_ENEMY,
			"prompt": "Use %s on..." % self.display_name,
		}
	else:
		return null
	
func highlight_option(_actor, option):
	if self.currently_highlighted_target != option:
		self.stop_highlight()
		self.start_highlight(option)
		
func start_highlight(option):
	self.currently_highlighted_target = option
	self.stored_material = self.currently_highlighted_target.material
	self.currently_highlighted_target.material = self.highlight_material
	
func stop_highlight():
	if self.currently_highlighted_target == null:
		return
		
	self.currently_highlighted_target.material = self.stored_material
	self.stored_material = null
	self.currently_highlighted_target = null
	
func push_parameter(parameter_name, value):
	assert(parameter_name == "target", "unknown parameter %s passed to attack action" % parameter_name)
	self.target = value
	self.stop_highlight()
	
func pop_parameter() -> bool:
	var was_target_present = self.target != null
	self.target = null
	self.stop_highlight()
	return was_target_present
	
func execute(_actor):
	assert(false, "should be implemented in child class")
