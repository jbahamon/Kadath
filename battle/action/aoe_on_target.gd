extends BattleAction

var target = null

var highlighted_targets = []
var stored_materials = {}

@onready var area_of_effect = $AreaOfEffect

func reset():
	self.target = null
	self.highlighted_targets = []
	self.stored_materials = {}
	self.area_of_effect.visible = false
	
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
	if self.highlighted_targets.size() > 0:
		self.stop_highlight()
	self.start_highlight(option)

func start_highlight(option):
	for target in await self.area_of_effect.get_actors_at(option.global_position):
		highlighted_targets.append(target)
		self.stored_materials[target.get_name()] = target.material
		target.material = self.highlight_material
	
	self.area_of_effect.visible = true
	
func stop_highlight():
	for target in self.highlighted_targets:
		target.material = self.stored_materials[target.get_name()]
	self.stored_materials = {}
	self.highlighted_targets = []
	self.area_of_effect.visible = false
	
func push_parameter(parameter_name, value):
	assert(parameter_name == "target", "unknown parameter %s passed to attack action" % parameter_name)
	self.target = value
	self.stop_highlight()
	
func pop_parameter() -> bool:
	var was_target_present = self.target != null
	self.target = null
	self.stop_highlight()
	return was_target_present
	
func execute(actor):
	assert(false, "should be implemented in child class")
