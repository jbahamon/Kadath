extends StatusEffect

func _init():
	self.defense_modifier = 0.5
	self.magic_defense_modifier = 0.5
	self.trigger = StatusEffect.Trigger.TURN_START

func get_id():
	return "defending"

func on_turn_start(turn: Turn, owner):
	if turn.actor.battler == owner:
		self.marked_for_removal = true
	
