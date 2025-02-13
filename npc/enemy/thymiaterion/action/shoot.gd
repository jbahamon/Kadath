extends "res://battle/action/simple_single_target.gd"

@onready var projectile = get_node("../../Projectile")
@onready var trail: CPUParticles2D = get_node("../../Projectile/CPUParticles2D")
@export var projectile_sound: AudioStream
@export var hit: Hit

func execute(actor):
	await get_tree().create_timer(0.525).timeout
	var origin = actor.global_position + Vector2(0, -80)
	var destination = target.battler.get_hitspot("Center")
	
	trail.direction = -origin.direction_to(destination)
	trail.emitting = true

	await self.shoot_projectile(
		actor, 
		projectile,
		{
			"origin": origin,
			"destination": destination,
			"speed": 250.0,
			"shoot_sound": self.projectile_sound
		}
	)
	trail.emitting = false
	await target.take_hit(actor, hit)
	await get_tree().create_timer(0.525).timeout
	self.reset()
