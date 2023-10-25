extends BattleAction

func reset():
	pass
	
func get_next_parameter_signature():
	return null
	
func push_parameter(_parameter_name, _value):
	pass
	
func pop_parameter():
	return null
	
func execute(actor):
	print("%s did nothing" % actor.display_name)
	
