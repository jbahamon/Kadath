extends "./healing_item.gd"

func get_targets_custom(actor, actors):
	return actor.get_allies(actors)
