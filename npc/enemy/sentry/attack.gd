extends "res://battle/action/simple_single_target.gd"

@onready var projectile = get_node("../../Projectile")

func execute(actor):
	var prev_hp = target.battler.health
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor)
	
	actor.play_anim("attack")
	
	var half_timer = get_tree().create_timer(0.525)
	var timer = get_tree().create_timer(1.05)
	
	var actions = [
		func (): 
			await timer.timeout
			actor.play_anim("idle"),
		func (): 
			await half_timer.timeout
			await self.shoot_projectile(actor, hit),
	]
	await DoAll.new(actions).execute()
	
	
	print(
		"%s attacked %s (HP: %d -> HP: %d)" % [
			actor.display_name, 
			target.display_name, 
			prev_hp, 
			target.battler.health
		])
	
	self.reset()

func shoot_projectile(actor, hit):
	var speed = 300.0
	var origin: Vector2 = actor.global_position + Vector2(0, -28)
	var destination = target.battler.get_hitspot("Center")
	
	var time = origin.distance_to(destination) / speed
	projectile.global_position = origin
	projectile.visible = true
	projectile.speed = origin.direction_to(destination) * speed
	
	await get_tree().create_timer(time).timeout
	
	projectile.visible = false
	projectile.position = Vector2.ZERO
	
	await target.take_hit(hit)
	
	
