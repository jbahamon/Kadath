extends Node

class_name BattlerAI

var interface: BattleUI

var reactions = []

func get_turn(_actors: Array) -> Turn:
	assert(false,"%s missing override of the get_turn method" % name)
	return null

func push_reaction(reaction):
	self.reactions.push_front(reaction)

func remove_reaction(reaction):
	self.reactions.erase(reaction)
	
func check_reactions(actor, hit, actors):
	for reaction in self.reactions:
		if reaction.is_triggered_by(actor, hit, actors):
			self.get_parent().pending_reaction = reaction
			return
