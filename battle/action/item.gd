extends BattleAction

var item = null
var targets = null


func reset():
	self.item = null
	self.targets = null
	
func get_next_parameter_signature():
	if self.item == null:
		return {
			"name": "item",
			"type": BattleAction.ActionArgument.ITEM,
			"prompt": "Choose an item",
		}
	elif self.targets == null and self.item.needs_targets():
		return {
			"name": "targets",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": self.item.target_type,
			"prompt": "Use %s on..." % self.item.name,
		}
	else:
		return 
	
func push_parameter(parameter_name, value):
	match parameter_name:
		"item":
			self.item = value
		"targets":
			self.targets = value
	
func pop_parameter() -> bool:
	if self.targets != null:
		self.targets = null
		return true
	elif self.item != null:
		self.item = null
		return true
	
	return false
	
func execute(actor):
	var used 
	if not self.item.needs_targets():
		used = await self.item.use([])
	elif self.item.is_multi_target():
		# Then it's a multi target option
		used = await self.item.use(self.targets.get_targets())
	else:
		# Then it's a single target
		used = await self.item.use([self.targets])
		
	if actor is PartyMember and used and self.item.consumed_after_use:
		EntitiesService.get_party().inventory.remove(self.item.id, 1)
	
	self.reset()
