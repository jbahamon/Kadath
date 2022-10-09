extends Node

class_name BattleAction

enum ActionArgument {
	TARGET,
	ITEM,
}

enum TargetType { 
	ONE_ENEMY,
	ALL_ENEMIES,
	
	SELF,
	ONE_ALLY,
	ALL_ALLIES,
}

export (String) var action_name: String
export (String) var description: String = "Base battle action"
export var should_retarget_on_missing_target: bool
export var disabled: bool

func get_signature():
	assert(false, "%s missing overwrite of the get_signature method" % name)

func execute(actor: Battler, args: Dictionary):
	assert(false, "%s missing overwrite of the execute method" % name)
