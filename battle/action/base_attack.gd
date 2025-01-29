extends "res://battle/action/simple_single_target.gd"


@export var walk_anim = "walk"
@export var attack_anim = "attack"
@export var jump_back_anim = "jump_back"
@export var idle_anim = "battle_idle"

@export var walk_speed = 150
@export var jump_back_speed = 180
@export var windup_time = 0.4

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
	hit.base_damage = actor.battler.physical_attack
	
	await self.move_to_target(actor, target, walk_speed, walk_anim)
	
	actor.play_anim(attack_anim)
	await actor.get_tree().create_timer(windup_time).timeout
	
	var actions = [
		func(): await self.target.take_hit(actor, hit),
		func(): 
			await actor.get_tree().create_timer(0.2).timeout
			actor.play_anim(jump_back_anim)
			
			await actor.move_to([original_position.x, original_position.y], jump_back_speed)
			actor.play_anim(idle_anim)
	]
	
	await DoAll.new(actions).execute()
	
	self.reset()
