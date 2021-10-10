class_name StatusEffectManager

var _effects: Array

var speed_modifier = 1

func add(battler, new_effect: StatusEffect):
	for effect in _effects:
		if effect.get_class() == new_effect.get_class():
			effect.refresh(new_effect)
			return
	
	_effects.append(new_effect)

func get_physical_attack_modifier():
	var modifier = 1.0
	for effect in _effects:
		modifier *= effect.physical_attack_modifier
	return modifier
	
func get_physical_defense_modifier():
	var modifier = 1.0
	for effect in _effects:
		modifier *= effect.physical_defense_modifier
	return modifier
	
func get_speed_modifier():
	var modifier = 1.0
	for effect in _effects:
		modifier *= effect.speed_modifier
	return modifier
