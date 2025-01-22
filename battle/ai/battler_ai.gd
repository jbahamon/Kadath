extends Node

class_name BattlerAI

var interface: BattleUI

var reactions = []

func get_turn(_actors: Array) -> Turn:
	assert(false,"%s missing override of the get_turn method" % name)
	return null

func push_reaction(reaction):
	if reaction not in self.reactions:
		self.reactions.push_front(reaction)

func remove_reaction(reaction):
	self.reactions.erase(reaction)
	
func check_reactions(actor, hit_from, hit, actors):
	for reaction in self.reactions:
		if reaction.check(actor, hit_from, hit, actors):
			return
