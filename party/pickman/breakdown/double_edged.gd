extends "res://battle/action/simple_single_target.gd"

@export var hit: Hit

func execute(actor):
	await DialogueService.open_global_dialogue("pickman_breakdown_attack")
	
	self.hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, self.hit)
	
	var original_position = actor.global_position
	await self.move_to_target(actor, target, 180, "run")
	actor.play_anim("feast")
	await get_tree().create_timer(0.2).timeout
	
	await DoAll.new([
		func(): await self.target.take_hit(actor, hit),
		func(): await actor.take_hit(actor, hit),
	]).execute()
	
	actor.play_anim("jump_back")
	await actor.move_to([original_position.x, original_position.y], 180)
	actor.play_anim("battle_idle")
	# Unlock 
	
	self.reset()
