extends StatusEffect

func _init():
	self.id = "defending"
	self.physical_defense_modifier = 5.0
	self.trigger = StatusEffect.Trigger.TURN_START
	
func on_turn_start(turn: Turn, owner):
	if turn.actor.battler == owner:
		self.marked_for_removal = true
	
