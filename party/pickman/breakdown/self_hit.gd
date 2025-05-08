extends BattleAction

@export var hit: Hit

func reset():
	pass
	
func get_next_parameter_signature():
	return null
	
func push_parameter(_parameter_name, _value):
	pass
	
func pop_parameter():
	return null
	
func execute(actor: Node):
	await DialogueService.open_global_dialogue("pickman_breakdown_hurt")
	await actor.get_tree().create_timer(0.4).timeout
	await actor.take_hit(actor, hit)
