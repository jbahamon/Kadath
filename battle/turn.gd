class_name Turn

var actor: Battler
var action: BattleAction
var targets: Array 

func play():
	assert(action != null && actor != null)
	
	action.execute(actor, targets)
	
	
