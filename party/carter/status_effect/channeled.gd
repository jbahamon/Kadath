extends StatusEffect

var channeled_icon = preload("res://battle/fx/status/channeled.tres")
var turn_counter = 1
func _init():
	self.icon = channeled_icon
	self.physical_attack_modifier = 2.0
	self.magic_attack_modifier = 2.0
	self.trigger = StatusEffect.Trigger.TURN_END | StatusEffect.Trigger.AFTER_ACTOR_DEATH

func get_id():
	return "channeled"

func on_turn_end(turn_actor, owner):
	
	if turn_actor.battler == owner:
		turn_counter -= 1
		if turn_counter < 0:
			self.marked_for_removal = true
	
func after_actor_death(turn_actor, owner):
	if turn_actor.battler == owner:
		self.marked_for_removal = true
