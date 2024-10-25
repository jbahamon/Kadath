extends BattleAction

@export var sacrifice_hit: Hit
var target
var sacrifice
var allies

func reset():
	self.target = null
	self.sacrifice = null
	self.allies = null
	
func execute(actor):
	actor.play_anim("attack")
	
	var remaining_hp = self.sacrifice.health
	sacrifice_hit.base_damage = remaining_hp
	
	await sacrifice.take_hit(sacrifice_hit)
	sacrifice.battler.health = 0
	
	var heals = allies.map(
		func(ally): return func (): await ally.heal(remaining_hp, true)
	)
	
	await DoAll.new(heals).execute()
	actor.play_anim("idle")
	self.reset()
