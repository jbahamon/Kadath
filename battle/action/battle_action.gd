extends Node

class_name BattleAction

enum ActionArgument {
	TARGET,
	ITEM,
}

enum TargetType {
	ONE_ALLY,
	ONE_ENEMY,
	ALL_ALLIES,
	ALL_ENEMIES,
	NONE,
	CUSTOM
}
@export var display_name: String
@export var description: String = "Base battle action"
@export var energy_cost: int = 0
@export var unlocked = true

const highlight_material = preload("res://utils/material/highlight.tres")

func is_disabled(actor):
	return actor is PartyMember and actor.battler.energy < self.energy_cost

func unlock():
	self.unlocked = true
	
func reset():
	assert(false, "%s missing overwrite of the reset method" % name)

func get_next_parameter_signature():
	assert(false, "%s missing overwrite of the get_next_parameter_signature method" % name)
	
func push_parameter(_parameter_name, _value):
	assert(false, "%s missing overwrite of the push_parameter method" % name)
	
func pop_parameter():
	assert(false, "%s missing overwrite of the pop_parameter method" % name)
	
func execute(_actor):
	assert(false,"%s missing overwrite of the execute method" % name)

func highlight(_option):
	pass
	
func get_targets_custom(_actor, _actors):
	assert(false,"%s missing overwrite of the get_targets_custom method" % name)

func get_targets(target_type, actor, actors):
	match target_type:
		TargetType.ONE_ALLY:
			return TargetUtil.one_ally(actor, actors)
		TargetType.ONE_ENEMY:
			return TargetUtil.one_enemy(actor, actors)
		TargetType.ALL_ALLIES:
			return TargetUtil.all_allies(actor, actors)
		TargetType.ALL_ENEMIES:
			return TargetUtil.all_enemies(actor, actors)
		TargetType.CUSTOM:
			return self.get_targets_custom(actor, actors)

func move_to_target(actor, target, speed, anim):
	var target_position 
	if target is not Vector2:
		target_position = target.battler.get_hitspot_for(actor.global_position)
	else:
		target_position = target
		
	var orientation = actor.global_position.direction_to(target_position)
	actor.set_orientation(orientation)
	actor.play_anim(anim)
	
	await actor.move_to([target_position.x, target_position.y], speed)
	
	if target is not Vector2:
		orientation = actor.global_position.direction_to(target.global_position)
		actor.set_orientation(orientation)

func shoot_projectile(actor, projectile, projectile_options: Dictionary):
	var speed = projectile_options["speed"]
	var origin = projectile_options["origin"]
	var destination = projectile_options["destination"]
	var time = origin.distance_to(destination) / speed
	var room = EnvironmentService.get_room()
	actor.battler.remove_child(projectile)
	
	room.add_child(projectile)
	
	if "shoot_sound" in projectile_options:
		FXService.play_sfx_at(projectile_options["shoot_sound"], origin)
	
	if projectile_options.get("rotate", false):
		projectile.rotation = VarsService.round_orientation_with_bias(actor.current_orientation).angle()
		
	projectile.global_position = origin
	projectile.visible = true
	projectile.speed = origin.direction_to(destination) * speed
	projectile.set_process(true)
		
	await get_tree().create_timer(time).timeout
	
	projectile.set_process(false)
	projectile.speed = Vector2.ZERO
	projectile.position = destination
	
	if projectile_options.get("skip_reset", false):
		return
		
	projectile.visible = false
	projectile.position = Vector2.ZERO
	
	room.remove_child(projectile)
	actor.battler.add_child(projectile)
	
