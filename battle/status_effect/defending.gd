extends StatusEffect

var defend_icon = preload("res://battle/fx/status/def_up.tres")
func _init():
	self.icon = defend_icon
	self.trigger = StatusEffect.Trigger.TURN_START | StatusEffect.Trigger.BEFORE_ACTOR_DEATH

func get_id():
	return "defending"

func on_turn_start(turn_actor, owner):
	if turn_actor.battler == owner:
		self.marked_for_removal = true
	
func before_actor_death(dead_actor, owner):
	if dead_actor.battler == owner:
		self.marked_for_removal = true

func get_vulnerability(_hit: Hit):
	return 0.5
