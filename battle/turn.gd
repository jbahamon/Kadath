class_name Turn

var actor
var action: BattleAction

func play():
	assert(action != null && actor != null)
	await action.execute(actor)
