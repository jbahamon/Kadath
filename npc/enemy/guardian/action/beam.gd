extends BattleAction

var targets = []

func reset():
	self.targets = []
	
func execute(actor):
	var hit = Hit.new()
	hit.type = Hit.Element.NONE
	hit.base_damage = floor(self.get_standard_attack_damage(actor) * 0.5)
	
	var hits = self.targets.map(func(target): return func(): await target.take_hit(hit))
	await DoAll.new(hits).execute()
	self.reset()
