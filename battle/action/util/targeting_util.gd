class_name TargetUtil

static var MultiTargetOption = preload("res://ui/04_templates/battle_ui/multi_target_option.gd")
static var multiple_options = MultiTargetOption.new()

static func one_enemy(actor, actors):
	var enemies = actor.get_enemies(actors)
	
	
static func one_ally(actor, actors):
	return actor.get_allies(actors)

static func all_enemies(actor, actors):
	TargetUtil.multiple_options.targets = actor.get_enemies(actors)
	TargetUtil.multiple_options.display_name = "All enemies"
	return [TargetUtil.multiple_options]

static func all_allies(actor, actors):
	TargetUtil.multiple_options.targets = actor.get_allies(actors)
	TargetUtil.multiple_options.display_name = "All enemies"
	return [TargetUtil.multiple_options]

static func oneself(actor, _actors):
	return [actor]
		
