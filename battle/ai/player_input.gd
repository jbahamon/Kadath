extends BattlerAI

class_name PlayerInputAI


func choose_action(actor: Battler):
	return yield(interface.choose_action(actor), "completed")


func choose_targets(actor: Battler, action: BattleAction, battlers: Array):
	# TODO include the targetting type here so the interface knows how to 
	# ask the player
	return yield(interface.choose_targets(battlers), "completed")
