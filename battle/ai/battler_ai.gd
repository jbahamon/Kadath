extends Node

class_name BattlerAI

var interface: BattleUI

func get_turn(_actors: Array) -> Turn:
	assert(false,"%s missing override of the get_turn method" % name)
	return null

