extends Node

class_name BattleAction

enum ActionArgument {
	TARGET,
	ITEM,
}

enum TargetType {
	ONE_ALLY,
	ONE_ENEMY,
	ALL_ALLIES,
	ALL_ENEMIES,
	NONE,
	CUSTOM
}
@export var display_name: String
@export var description: String = "Base battle action"
@export var energy_cost: int = 0
@export var unlocked = true

const highlight_material = preload("res://utils/material/highlight.tres")

func is_disabled(actor):
	return actor is PartyMember and actor.battler.energy < self.energy_cost

func unlock():
	self.unlocked = true
	
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

func highlight(_option):
	pass
	
func get_targets_custom(_actor, _actors):
	assert(false,"%s missing overwrite of the get_targets_custom method" % name)

func get_targets(target_type, actor, actors):
	match target_type:
		TargetType.ONE_ALLY:
			return TargetUtil.one_ally(actor, actors)
		TargetType.ONE_ENEMY:
			return TargetUtil.one_enemy(actor, actors)
		TargetType.ALL_ALLIES:
			return TargetUtil.all_allies(actor, actors)
		TargetType.ALL_ENEMIES:
			return TargetUtil.all_enemies(actor, actors)
		TargetType.CUSTOM:
			return self.get_targets_custom(actor, actors)
