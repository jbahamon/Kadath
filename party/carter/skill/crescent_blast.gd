extends "res://battle/action/aoe_on_target.gd"

@export var aoe_power: float
@export var charge_sound: AudioStream
@export var throw_sound: AudioStream
@export var explosion_sound: AudioStream
@export var main_hit: Hit
@onready var projectile: AnimatedSprite2D = get_node("../../../BlastProjectile")

func execute(actor):
	self.main_hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, self.main_hit)
	
	var previous_material = actor.material
	actor.material = highlight_material
	actor.battler.spend_energy(self.energy_cost)
	actor.set_orientation(actor.global_position.direction_to(self.target.global_position))
	actor.play_anim("blast")
	var targets = await self.area_of_effect.get_actors_at(self.target.global_position)
	FXService.play_sfx_at(self.charge_sound, actor.global_position)
	await actor.get_tree().create_timer(1).timeout
	
	var actor_party_member = actor is PartyMember
	
	var hits = [
		func (): await self.target.take_hit(actor, main_hit)
	]
	var additional_hits = targets.filter(
		func(aoe_target): return (aoe_target is PartyMember) != actor_party_member and aoe_target != self.target
	).map(
		func (aoe_target):
			var hit = Hit.new()
			hit.type = Hit.Element.CHAOS
			hit.base_damage = self.aoe_power
			hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, hit)
			return func (): 
				await aoe_target.take_hit(actor, hit)
		
	)
	hits.append_array(additional_hits)
	
	actor.material = previous_material
	
	FXService.play_sfx_at(self.throw_sound, actor.global_position)
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
	FXService.play_sfx_at(self.explosion_sound, target.battler.get_hitspot("Center"))
	
	await DoAll.new([
		func(): 
			await DoAll.new(hits).execute()
			await actor.get_tree().create_timer(0.5).timeout,
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
