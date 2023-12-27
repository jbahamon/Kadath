extends BattleAction

var Defending = preload("res://battle/status_effect/defending.gd")

func reset():
	pass
	
func get_next_parameter_signature():
	return null
	
func push_parameter(_parameter_name, _value):
	assert(false, "this action requires no parameters")
	
func pop_parameter() -> bool:
	return false
	
func execute(actor):
	actor.battler.status_effects.add(Defending.new())
	
