extends BattleAction

const blurb = "Consume"
@export var sacrifice_hit: Hit
@export var sacrifice_scream: AudioStream
@export var heal_sound: AudioStream
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
	
	var remaining_hp: int = self.sacrifice.health
	sacrifice_hit.base_damage = remaining_hp
	
	(func ():
		await actor.get_tree().create_timer(1.2).timeout
		FXService.play_sfx_at(self.sacrifice_scream, self.sacrifice.global_position)
	).call()
	await self.sacrifice.take_hit(actor, sacrifice_hit)
	self.sacrifice.battler.health = 0
	var heals = allies.map(
		func(ally): return func (): await ally.heal(remaining_hp, true)
	)
	FXService.play_sfx_at(self.heal_sound, actor.global_position)
	await DoAll.new(heals).execute()
	BattleService.announce("")
	actor.play_anim("idle")
	self.reset()
