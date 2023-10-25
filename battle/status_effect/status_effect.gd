class_name StatusEffect

enum Trigger {
	TURN_START = 1,
	TURN_END = 2,
	ACTOR_DEAD = 4,
}

var id: String
var trigger = 0
var speed_modifier: float = 1.0
var physical_defense_modifier: float = 1.0
var physical_attack_modifier: float = 1.0
var marked_for_removal = false

func refresh(_effect: StatusEffect):
	pass
