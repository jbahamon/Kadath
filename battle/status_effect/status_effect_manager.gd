class_name StatusEffectManager

signal added_or_removed(effects)

var size:
	get:
		return self._effects.size()
		
var physical_attack_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects.values():
			modifier *= effect.physical_attack_modifier
		return modifier
	
var physical_defense_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects.values():
			modifier *= effect.physical_defense_modifier
		return modifier

var magic_attack_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects.values():
			modifier *= effect.magic_attack_modifier
		return modifier
	
var magic_defense_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects.values():
			modifier *= effect.magic_defense_modifier
		return modifier
		
var speed_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects.values():
			modifier *= effect.speed_modifier
		return modifier

var _effects: Dictionary
var owner

var turn_start_triggers = 0
var turn_end_triggers = 0
var before_death_triggers = 0
var after_death_triggers = 0

func _init(init_owner):
	self._effects = {}
	self.owner = init_owner

func _destroy():
	self.owner = null

func clear():
	self._effects = {}
	
func add(new_effect: StatusEffect):
	if new_effect.get_id() in self._effects:
		new_effect = self._effects[new_effect.get_id()]
		new_effect.refresh(new_effect)
	else:
		self._effects[new_effect.get_id()] = new_effect
	
	self.added_or_removed.emit(self._effects.values())
	
	if new_effect.trigger & StatusEffect.Trigger.ADD:
		await new_effect.on_add(self.owner)
	
	if new_effect.trigger & StatusEffect.Trigger.TURN_START:
		self.turn_start_triggers += 1
		if self.turn_start_triggers == 1:
			BattleService.observe_event(BattleService.Event.TURN_START, self)
	
	if new_effect.trigger & StatusEffect.Trigger.TURN_END:
		self.turn_end_triggers += 1
		if self.turn_end_triggers == 1:
			BattleService.observe_event(BattleService.Event.TURN_END, self)
	
		
	if new_effect.trigger & StatusEffect.Trigger.BEFORE_ACTOR_DEATH:
		self.before_death_triggers += 1
		if self.before_death_triggers == 1:
			BattleService.observe_event(BattleService.Event.BEFORE_ACTOR_DEATH, self)

	if new_effect.trigger & StatusEffect.Trigger.AFTER_ACTOR_DEATH:
		self.after_death_triggers += 1
		if self.after_death_triggers == 1:
			BattleService.observe_event(BattleService.Event.AFTER_ACTOR_DEATH, self)
	
func remove(effect_id: String):
	var effect = self._effects.get(effect_id)
	if effect == null:
		return false
	
	if effect.trigger & StatusEffect.Trigger.REMOVE:
		effect.on_remove(self.owner)
	
	self._effects.erase(effect_id)
	
	if effect.trigger & StatusEffect.Trigger.TURN_START:
		self.turn_start_triggers -= 1
		if self.turn_start_triggers <= 0:
			BattleService.stop_observe_event(BattleService.Event.TURN_START, self)
	
	if effect.trigger & StatusEffect.Trigger.TURN_END:
		self.turn_end_triggers -= 1
		if self.turn_end_triggers <= 0:
			BattleService.stop_observe_event(BattleService.Event.TURN_END, self)
		
	return true

func on_turn_start(turn_actor):
	var to_remove = []
	for effect in self._effects.values():
		if effect.trigger & StatusEffect.Trigger.TURN_START:
			effect.on_turn_start(turn_actor, owner)
			
			if effect.marked_for_removal:
				to_remove.append(effect.get_id())
			
	for effect_id in to_remove:
		self.remove(effect_id)
		
	if to_remove.size() > 0:
		self.added_or_removed.emit(self._effects.values())

func on_turn_end(turn_actor):
	var to_remove = []
	for effect in self._effects.values():
		if effect.trigger & StatusEffect.Trigger.TURN_END:
			effect.on_turn_end(turn_actor, owner)
			
			if effect.marked_for_removal:
				to_remove.append(effect.get_id())
			
	for effect_id in to_remove:
		self.remove(effect_id)
	
	if to_remove.size() > 0:
		self.added_or_removed.emit(self._effects.values())

func before_actor_death(actor):
	var to_remove = []
	for effect in self._effects.values():
		if effect.trigger & StatusEffect.Trigger.BEFORE_ACTOR_DEATH:
			effect.before_actor_death(actor, owner)
			
			if effect.marked_for_removal:
				to_remove.append(effect.get_id())
	
	if to_remove.size() > 0:
		self.added_or_removed.emit(self._effects.values())

func after_actor_death(actor):
	var to_remove = []
	for effect in self._effects.values():
		if effect.trigger & StatusEffect.Trigger.AFTER_ACTOR_DEATH:
			effect.after_actor_death(actor, owner)
			
			if effect.marked_for_removal:
				to_remove.append(effect.get_id())
				
	for effect_id in to_remove:
		self.remove(effect_id)
	
	if to_remove.size() > 0:
		self.added_or_removed.emit(self._effects.values())
