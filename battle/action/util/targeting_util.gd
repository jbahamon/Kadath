class_name TargetUtil

static var MultiTargetOption = preload("res://ui/04_templates/battle_ui/multi_target_option.gd")
static var multiple_options = MultiTargetOption.new()

static func one_enemy(actor, actors) -> Array:
	return actor.get_enemies(actors).filter(func(other_actor): return other_actor.is_alive)
	
static func one_ally(actor, actors) -> Array:
	return actor.get_allies(actors).filter(func(other_actor): return other_actor.is_alive)

static func all_enemies(actor, actors) -> Array:
	TargetUtil.multiple_options.targets = actor.get_enemies(actors).filter(func(other_actor): return other_actor.is_alive)
	TargetUtil.multiple_options.display_name = "All enemies"
	return [TargetUtil.multiple_options]

static func all_allies(actor, actors) -> Array:
	TargetUtil.multiple_options.targets = actor.get_allies(actors).filter(func(other_actor): return other_actor.is_alive)	
	TargetUtil.multiple_options.display_name = "All enemies"
	return [TargetUtil.multiple_options]

static func oneself(actor, _actors) -> Array:
	return [actor]
		
