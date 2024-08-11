extends BattleAction

var target
var sacrifice
var allies

func reset():
	self.target = null
	self.sacrifice = null
	self.allies = null
	
func execute(actor):
	
	var remaining_hp = self.sacrifice.health
	await sacrifice.battler.show_toast("%d" % remaining_hp, Color.WHITE)
	sacrifice.battler.stats.health = 0
	sacrifice.battler.emit_signal("died", sacrifice)
	
	var heals = []
	
	for ally in allies:
		heals.append(
			func (): await ally.heal(remaining_hp, true)
		)
	await DoAll.new(heals).execute()
	self.reset()
