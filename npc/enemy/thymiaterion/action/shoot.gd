extends "res://battle/action/simple_single_target.gd"

@onready var projectile = get_node("../../Projectile")
@onready var trail: CPUParticles2D = get_node("../../Projectile/CPUParticles2D")

func execute(actor):
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = actor.battler.physical_attack
	
	await get_tree().create_timer(0.525).timeout
	await self.shoot_projectile(actor, hit)
	await get_tree().create_timer(0.525).timeout
	self.reset()

func shoot_projectile(actor, hit):
	var speed = 250.0
	var origin: Vector2 = actor.global_position + Vector2(0, -80)
	var destination = target.battler.get_hitspot("Center")
	
	var time = origin.distance_to(destination) / speed
	var room = EnvironmentService.get_room()
	actor.battler.remove_child(projectile)
	room.add_child(projectile)
	
	projectile.global_position = origin
	projectile.visible = true
	
	var direction = origin.direction_to(destination)
	trail.direction = -direction
	trail.emitting = true
	projectile.speed = direction * speed
	
	await get_tree().create_timer(time).timeout
	
	trail.emitting = false
	projectile.visible = false
	projectile.position = Vector2.ZERO
	
	room.remove_child(projectile)
	actor.battler.add_child(projectile)
	
	await target.take_hit(actor, hit)
	
	
	
