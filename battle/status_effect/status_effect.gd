class_name StatusEffect

enum Trigger {
	TURN_START = 1,
	TURN_END = 2,
	BEFORE_ACTOR_DEATH = 4,
	AFTER_ACTOR_DEATH = 8,
	ADD = 16,
	REMOVE = 32,
}

var icon: SpriteFrames
var trigger = 0
var speed_modifier: float = 1.0
var physical_defense_modifier: float = 1.0
var physical_attack_modifier: float = 1.0
var magic_defense_modifier: float = 1.0
var magic_attack_modifier: float = 1.0
var marked_for_removal = false


func get_id() -> String:
	return ""
	
func refresh(_effect: StatusEffect):
	pass
