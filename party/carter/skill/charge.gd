extends BattleAction

var Charged = preload("res://party/carter/status_effect/charged.gd")

func reset():
	pass
	
func get_next_parameter_signature():
	return null
	
func push_parameter(_parameter_name, _value):
	assert(false, "this action requires no parameters")
	
func pop_parameter() -> bool:
	return false
	
func execute(actor):
	#actor.play_anim("")
	
	actor.battler.status_effects.add(Charged.new())
	
