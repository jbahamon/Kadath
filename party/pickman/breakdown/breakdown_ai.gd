extends "res://battle/ai/non_player_ai.gd"

@onready var self_hit = $SelfHit
@onready var double_edged = $DoubleEdged

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
		action = double_edged
	else:		
		action = self_hit

		
	r = randf()
	return action
	
func fill_action_parameters(action: BattleAction, actor, actors: Array):
	if action == double_edged:
		action.target = TargetUtil.one_enemy(actor, actors).pick_random()
	
