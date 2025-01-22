extends StatusEffect

func _init():
	self.physical_defense_modifier = 0.5
	self.magic_defense_modifier = 0.5
	self.trigger = StatusEffect.Trigger.TURN_START | StatusEffect.Trigger.BEFORE_ACTOR_DEATH

func get_id():
	return "defending"

func on_turn_start(turn_actor, owner):
	if turn_actor.battler == owner:
		self.marked_for_removal = true
	
func before_actor_death(dead_actor, owner):
	if dead_actor.battler == owner:
		self.marked_for_removal = true
