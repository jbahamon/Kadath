extends "res://battle/action/base_skill.gd"

@export var power: float
@export var aoe_power: float
@onready var area_of_effect: Node2D = $AreaOfEffect

var target = null

func reset():
	self.target = null
	self.area_of_effect.reset()
	
func get_next_parameter_signature():
	if target == null:
		return {
			"name": "target",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ONE_ENEMY
		}
	else:
		return null
	
func push_parameter(parameter_name, value):
	assert(parameter_name == "target", "unknown parameter %s passed to attack action" % parameter_name)
	self.target = value
	
func pop_parameter() -> bool:
	var was_target_present = self.target != null
	self.target = null
	return was_target_present
	
func execute(actor):
	actor.battler.stats.spend_energy(self.cost)
	var targets = await self.area_of_effect.get_actors_at(self.target.global_position)
	
	var actor_party_member = actor is PartyMember
	
	var first_hit = Hit.new()
	first_hit.type = Hit.Element.METAL
	first_hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.power

	var hits = [
		func (): await self.target.take_hit(first_hit)
	]
	for aoe_target in targets:
		if (aoe_target is PartyMember) != actor_party_member and aoe_target != self.target:
			var hit = Hit.new()
			hit.type = Hit.Element.METAL
			hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.aoe_power
			hits.append(
				func (): await aoe_target.take_hit(hit)
			)
	
	await DoAll.new(hits).execute()
	
	self.reset()
	
