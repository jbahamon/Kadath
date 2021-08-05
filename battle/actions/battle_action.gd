extends Node

class_name BattleAction

var initialized = false

# Since Actions can be instanced by code (ie skills) these
# actions doesn't have an owner, that's why we get the owner
# from it's parent (BattlerActions.gd)
onready var actor: Battler = get_parent().get_owner()
export (String) var description: String = "Base battle action"


func initialize(battler: Battler) -> void:
	actor = battler
	initialized = true


func execute(targets: Array):
	assert(initialized)
	print("%s missing overwrite of the execute method" % name)
	return false


func can_use() -> bool:
	return true
