extends "res://battle/action/simple_single_target.gd"

@onready var projectile = get_node("../../Projectile")

func execute(actor):
	var prev_hp = target.battler.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = actor.battler.physical_attack
	
	actor.play_anim("attack")
	
	var half_timer = get_tree().create_timer(0.525)
	var timer = get_tree().create_timer(1.05)
	
	var actions = [
		func (): 
			await timer.timeout
			actor.play_anim("idle"),
		func (): 
			await half_timer.timeout
			await self.shoot_projectile(
				actor, 
				projectile,
				{
					"origin": actor.global_position + Vector2(0, -28),
					"destination": target.battler.get_hitspot("Center"),
					"speed": 300.0,
				}
			)
			await target.take_hit(actor, hit)
	]
	await DoAll.new(actions).execute()
	
	self.reset()
