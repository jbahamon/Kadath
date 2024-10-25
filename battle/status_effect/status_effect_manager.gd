class_name StatusEffectManager

var size:
	get:
		return self._effects.size()
		
var physical_attack_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects:
			modifier *= effect.physical_attack_modifier
		return modifier
	
var physical_defense_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects:
			modifier *= effect.physical_defense_modifier
		return modifier
		
var speed_modifier:
	get:
		var modifier = 1.0
		for effect in self._effects:
			modifier *= effect.speed_modifier
		return modifier

var _effects: Array
var owner: Battler

func _init(init_owner):
	self._effects = []
	self.owner = init_owner
	
func _destroy():
	self.owner = null

func clear():
	self._effects = []
	
func add(new_effect: StatusEffect):
	for effect in self._effects:
		if effect.get_id() == new_effect.get_id():
			effect.refresh(new_effect)
			return
	
	_effects.append(new_effect)
	new_effect.on_add(self.owner)
	
func remove(effect_id: StatusEffect):
	var to_remove = []
	for effect in self._effects:
		if effect.get_id() == effect_id:
			to_remove.append(effect)
	
	for effect in to_remove:
		effect.on_remove(self.owner)
		self._effects.erase(effect)
	
	return to_remove.size() > 0

func on_turn_start(turn: Turn) -> bool:
	var to_remove = []
	
	for effect in self._effects:
		if effect.trigger & StatusEffect.Trigger.TURN_START:
			effect.on_turn_start(turn, owner)
			
			if effect.marked_for_removal:
				to_remove.append(effect)
			
	for effect in to_remove:
		effect.on_remove(self.owner)
		self._effects.erase(effect)
		
	return to_remove.size() > 0
	
func on_turn_end(turn: Turn):
	var to_remove = []
	
	for effect in self._effects:
		if effect.trigger & StatusEffect.Trigger.TURN_END:
			effect.on_turn_end(turn, owner)
			
			if effect.marked_for_removal:
				to_remove.append(effect)
			
	for effect in to_remove:
		effect.on_remove(self.owner)
		self._effects.erase(effect)

func has(id):
	for effect in self._effects:
		if effect.get_id() == id:
			return true
	return false

func on_actor_dead(actor):
	var to_remove = []
	
	for effect in self._effects:
		if effect.trigger & StatusEffect.Trigger.ACTOR_DEAD:
			effect.on_actor_dead(actor, owner)
			
			if effect.marked_for_removal:
				to_remove.append(effect)
			
	for effect in to_remove:
		self._effects.erase(effect)

