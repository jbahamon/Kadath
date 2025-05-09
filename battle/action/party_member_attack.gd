extends "res://battle/action/simple_single_target.gd"

@export var run_speed = 180
@export var crit_speed = 360

@export var jump_back_speed = 220
@export var windup_time = 16.0/60.0
@export var crit_windup_time = 17.0/60.0

@export var hit_time = 24.0/60.0
@export var crit_hit_time = 43.0/60.0

@export var hit: Hit

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
	var is_crit = false #randf() < actor.equipped_weapon.crit_chance
	
	if not self.hit.fixed_damage:
		self.hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, self.hit) * (1.5 if is_crit else 1.0)
		
	await self.move_to_target(
		actor, 
		target, 
		crit_speed if is_crit else run_speed, 
		"crit_start" if is_crit else "run"
	)
	
	actor.play_anim("crit" if is_crit else "attack")
	await actor.get_tree().create_timer(crit_windup_time if is_crit else windup_time).timeout
	
	var actions = [
		func(): await self.target.take_hit(actor, hit),
		func(): 
			await actor.get_tree().create_timer(crit_hit_time if is_crit else hit_time).timeout
			actor.play_anim("jump_back")
			await actor.move_to([original_position.x, original_position.y], jump_back_speed)
			actor.play_anim("battle_idle")
	]
	
	if is_crit:
		actions.append(
			FXService.env_shake(1, Vector2(3, 8), crit_hit_time/2.0).shake_finished
		)
	await DoAll.new(actions).execute()
	
	self.reset()
