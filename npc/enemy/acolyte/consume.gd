extends BattleAction

const blurb = "Consume"
@export var sacrifice_hit: Hit
var sacrifice
var allies

func get_next_parameter_signature():
	if sacrifice == null:
		return {
			"name": "target",
			"type": BattleAction.ActionArgument.TARGET,
			"prompt": "Choose a sacrifice for %s" % self.display_name,
			"targeting_type": BattleAction.TargetType.ONE_ALLY,
		}
	elif allies == null:
		return {
			"name": "allies",
			"type": BattleAction.ActionArgument.TARGET,
			"prompt": "Who will be healed?",
			"targeting_type": BattleAction.TargetType.ALL_ALLIES,
		}
	else:
		return null
		
func reset():
	self.sacrifice = null
	
func execute(actor):
	BattleService.announce(self.blurb)
	actor.play_anim("attack")
	
	var remaining_hp = self.sacrifice.health
	sacrifice_hit.base_damage = remaining_hp
	
	await self.sacrifice.take_hit(sacrifice_hit)
	self.sacrifice.battler.health = 0
	
	var heals = allies.map(
		func(ally): return func (): await ally.heal(remaining_hp, true)
	)
	
	await DoAll.new(heals).execute()
	BattleService.announce("")
	actor.play_anim("idle")
	self.reset()
