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
	NONE,
}

@export var display_name: String
@export var description: String = "Base battle action"

func get_standard_attack_damage(actor):
	return actor.battler.physical_attack * 5

func is_disabled():
	return false

func reset():
	assert(false, "%s missing overwrite of the reset method" % name)

func get_next_parameter_signature():
	assert(false, "%s missing overwrite of the get_next_parameter_signature method" % name)
	
func push_parameter(_parameter_name, _value):
	assert(false, "%s missing overwrite of the push_parameter method" % name)
	
func pop_parameter():
	assert(false, "%s missing overwrite of the pop_parameter method" % name)
	
func execute(_actor):
	assert(false,"%s missing overwrite of the execute method" % name)
