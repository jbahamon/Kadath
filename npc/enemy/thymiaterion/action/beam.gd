extends BattleAction

var Counter = preload("res://npc/enemy/thymiaterion/reaction/counter.gd")

var targets = []
var counter_reaction = Counter.new()

func reset():
	self.targets = []
	
func execute(actor):
	var ai: BattlerAI = actor.battler.ai
	ai.push_reaction(self.counter_reaction)
