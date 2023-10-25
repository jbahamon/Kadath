class_name Turn

var actor
var action: BattleAction

func play():
	assert(action != null && actor != null)
	action.execute(actor)
