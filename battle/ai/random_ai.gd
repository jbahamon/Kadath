extends BattlerAI

class_name RandomAI


func choose_action(actor: Battler) -> BattleAction:
	# Select an action to perform in combat
	# Can be based on state of the actor
	return actor.get_actions()[0]


func choose_targets(actor: Battler, action: BattleAction, battlers: Array) -> Array:
	# Chooses a target to perform an action on
	match action.targeting_type:
		BattleAction.TargetingType.ALL_ALLIES:
			return self.get_allies(actor, battlers)
		BattleAction.TargetingType.ONE_ALLY:
			var allies = self.get_allies(actor, battlers)
			return [allies[randi() % allies.size()]]
		BattleAction.TargetingType.ALL_ENEMIES:
			return self.get_enemies(actor, battlers)
		BattleAction.TargetingType.ONE_ENEMY:
			var enemies = self.get_enemies(actor, battlers)
			return [enemies[randi() % enemies.size()]]
		BattleAction.TargetingType.SELF:
			return [actor]
		_:
			return []
