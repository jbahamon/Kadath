extends "res://battle/ai/non_player_ai.gd"

@onready var attack = get_node("../../Battler/Actions/Attack")
@onready var crescent = get_node("../../Battler/Actions/Skill/CrescentBlast")
@onready var charge = get_node("../../Battler/Actions/Skill/Charge")

const party_member_bias = [
	PartyMember.Id.VOLKI, 
	PartyMember.Id.PICKMAN,
	PartyMember.Id.SYLVIE, 
	PartyMember.Id.ZKAUBA,
]

func choose_action(_actor, _actors: Array):
	var r = randf()
	var action
	
	if r < 0.8:
		action = attack
	else:
		action = crescent

		
	r = randf()
	await DialogueService.open_global_dialogue("carter_breakdown")

	return action
	
func fill_action_parameters(action: BattleAction, actor, actors: Array):
	var current_parameter_signature = action.get_next_parameter_signature()
	
	while current_parameter_signature != null:
		var new_parameter = self.get_action_parameter(
			actor, 
			action,
			actors, 
			current_parameter_signature
		)
	
		action.push_parameter(current_parameter_signature["name"], new_parameter)
			
		current_parameter_signature = action.get_next_parameter_signature()
	
	
func get_action_parameter(actor, action: BattleAction, actors: Array, argument_signature: Dictionary):
	match argument_signature["type"]:
		BattleAction.ActionArgument.TARGET:
			var targets: Array = action.get_targets(argument_signature["targeting_type"], actor, actors)
			var total = 0.0
			for target in targets:
				total += 2.0 if self.is_biased_against(target) else 1.0
			var r = randf()
			var acc = 0.0
			for target in targets:
				acc += (2.0 if self.is_biased_against(target) else 1.0)/total
				if acc >= r:
					return target
				
		BattleAction.ActionArgument.ITEM:
			assert(false) #,"not yet implemented!")

func is_biased_against(actor):
	if actor is Enemy:
		return actor.enemy_id in ["thymiaterion", "acolyte"]
	else:
		return (actor as PartyMember).id in party_member_bias
		
	
