class_name Turn

var actor
var action: BattleAction
var action_args: Dictionary 

func play():
	assert(action != null && actor != null)
	action.execute(actor)
