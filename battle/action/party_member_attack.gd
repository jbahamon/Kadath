extends "res://battle/action/simple_single_target.gd"

var base_hit = preload("res://battle/action/party_attack_hit.tres")

@export var walk_speed = 180
@export var crit_speed = 360

@export var jump_back_speed = 220
@export var windup_time = 16.0/60.0
@export var crit_windup_time = 17.0/60.0

@export var hit_time = 24.0/60.0
@export var crit_hit_time = 43.0/60.0

@export var hit: Hit = base_hit

func get_next_parameter_signature():
	if target == null:
		return {
			"name": "target",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": BattleAction.TargetType.ONE_ENEMY,
			"prompt": "Choose a target",
		}
	else:
		return null

func execute(actor):
	var original_position = actor.global_position
	var is_crit = randf() < 0 #actor.equipped_weapon.crit_chance
	
	hit.base_damage = 1 # actor.battler.physical_attack * (1.5 if is_crit else 2.0)
	
	await self.move_actor_to_position(actor, is_crit)
	
	actor.play_anim("crit" if is_crit else "attack")
	await actor.get_tree().create_timer(crit_windup_time if is_crit else windup_time).timeout
	
	var actions = [
		func(): await self.target.take_hit(actor, hit),
		func(): 
			await actor.get_tree().create_timer(crit_hit_time if is_crit else hit_time).timeout
			actor.play_anim("jump_back")
			await actor.move_to([original_position.x, original_position.y], jump_back_speed)
			actor.play_anim("battle_idle")
			
			var enemies: Array = BattleService.get_non_party_actors() if actor is PartyMember else BattleService.get_party_actors()
			var enemy_center = enemies.reduce(func(accum, actor): return accum + actor.global_position, Vector2.ZERO) / enemies.size()
			actor.set_orientation(actor.global_position.direction_to(enemy_center))
	]
	
	if is_crit:
		actions.append(
			func(): 
				CameraService.shake(CutsceneInstruction.ExecutionMode.PLAY, 1, Vector2(3, 8), crit_hit_time/2.0)
		)
	await DoAll.new(actions).execute()
	
	self.reset()

func move_actor_to_position(actor, is_crit):
	var target_position = target.battler.get_hitspot_for(actor.global_position)
	var orientation = actor.global_position.direction_to(target_position)
	actor.set_orientation(orientation)
	
	actor.play_anim("crit_start" if is_crit else "run")
	
	await actor.move_to([target_position.x, target_position.y], crit_speed if is_crit else walk_speed)
	
	if not is_crit:
		actor.set_orientation(actor.global_position.direction_to(target.global_position))
