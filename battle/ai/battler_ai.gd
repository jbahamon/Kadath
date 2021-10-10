extends Node

class_name BattlerAI

var interface: BattleUI

func get_turn(battlers: Array) -> Turn:
	# Select an action to perform in combat
	# Can be based on state of the actor
	var actor: Battler = get_parent()
	var action = self.choose_action(actor)
	
	if action is GDScriptFunctionState:
		action = yield(action, "completed")
	
	var targets = self.choose_targets(actor, action, battlers)
	
	if targets is GDScriptFunctionState:
		targets = yield(targets, "completed")
	
	var turn = Turn.new()
	turn.actor = actor
	turn.action = action
	turn.targets = targets
	
	return turn
		
func choose_action(actor: Battler) -> BattleAction:
	# Select an action to perform in combat
	# Can be based on state of the actor
	return null


func choose_targets(actor: Battler, action: BattleAction, battlers: Array):
	# Chooses a target to perform an action on
	return []

func get_allies(actor: Battler, battlers: Array):
	var allies = []
	for battler in battlers:
		if battler.is_party_member == actor.is_party_member:
			allies.append(battler)
	return allies
	
func get_enemies(actor: Battler, battlers: Array):
	var enemies = []
	for battler in battlers:
		if battler.is_party_member != actor.is_party_member:
			enemies.append(battler)
	return enemies
