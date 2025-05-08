extends StatusEffect

var stress_icon = load("res://battle/fx/status/stress.tres")
var remaining_turns: int = 4
var original_ai = null
func _init():
	self.icon = stress_icon
	self.attack_modifier = 0.75
	self.magic_attack_modifier = 0.75
	self.defense_modifier = 0.75
	self.magic_defense_modifier = 0.75
	self.trigger = StatusEffect.Trigger.TURN_START | StatusEffect.Trigger.TURN_END | StatusEffect.Trigger.BEFORE_ACTOR_DEATH | StatusEffect.Trigger.ADD | StatusEffect.Trigger.REMOVE

func get_id():
	return "breakdown"

func on_add(owner):
	await owner.get_parent().start_breakdown()
	
func on_turn_start(turn_actor, owner):
	if turn_actor.battler == owner:
		remaining_turns -= 1
		if remaining_turns <= 0:
			self.marked_for_removal = true

func on_turn_end(_turn_actor, owner):
	if owner.energy > 0:
		self.marked_for_removal = true

func before_actor_death(dead_actor, owner):
	if dead_actor.battler == owner:
		owner.set_energy(max(1, owner.energy))
		self.marked_for_removal = true

func on_remove(owner, battle_ended):
	await owner.get_parent().stop_breakdown(battle_ended)
	
