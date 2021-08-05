extends BattlerAI

var interface: Node


func choose_action(actor: Battler, battlers: Array):
	return yield(interface.choose_action(actor), "completed")


func choose_targets(actor: Battler, action, battlers: Array):
	return yield(interface.choose_targets(battlers), "completed")
