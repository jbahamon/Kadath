extends Node

class_name BattleAction

enum TargetingType { 
	ONE_ENEMY,
	ALL_ENEMIES,
	
	SELF,
	ONE_ALLY,
	ALL_ALLIES
}

export (String) var description: String = "Base battle action"
export (TargetingType) var targeting_type: int
export var should_retarget_on_missing_target: bool

func execute(actor: Battler, targets: Array):
	print("%s missing overwrite of the execute method" % name)
	return false

