extends "res://battle/action/aoe_on_target.gd"

@export var power: float
@export var aoe_power: float

@onready var projectile: AnimatedSprite2D = get_node("../../../BlastProjectile")

func execute(actor):
	var previous_material = actor.material
	actor.material = highlight_material
	actor.battler.spend_energy(self.energy_cost)
	
	actor.play_anim("blast")
	var targets = await self.area_of_effect.get_actors_at(self.target.global_position)
	
	await actor.get_tree().create_timer(0.67).timeout
	
	var actor_party_member = actor is PartyMember
	
	var first_hit = Hit.new()
	first_hit.type = Hit.Element.METAL
	first_hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.power
	
	var hits = [
		func (): await self.target.take_hit(actor, first_hit)
	]
	var additional_hits = targets.filter(
		func(aoe_target): return (aoe_target is PartyMember) != actor_party_member and aoe_target != self.target
	).map(
		func (aoe_target):
			var hit = Hit.new()
			hit.type = Hit.Element.METAL
			hit.base_damage = (actor.battler.stats.level + actor.battler.stats.magic_attack) * self.aoe_power
			return func (): 
				await aoe_target.take_hit(actor, hit)
		
	)
	hits.append_array(additional_hits)
	
	actor.material = previous_material
	await self.shoot_projectile(
		actor,
		projectile,
		{
			"origin": actor.global_position + self.get_starting_position(actor),
			"destination": target.battler.get_hitspot("Center"),
			"speed": 250.0,
			"rotate": true,
		}
	)
		
	await DoAll.new([
		func(): 
			await actor.get_tree().create_timer(0.5).timeout
			await DoAll.new(hits).execute(),
		func(): area_of_effect.animate()
	]).execute()
	
	actor.play_anim("battle_idle")
	
	self.reset()
	
func get_starting_position(actor):
	match VarsService.round_orientation_with_bias(actor.current_orientation):
		Vector2.UP:
			return Vector2(0, -18)
		Vector2.DOWN:
			return Vector2(0, 6)
		Vector2.LEFT:
			return Vector2(-21, -12)
		Vector2.RIGHT:
			return Vector2(21, -12)
