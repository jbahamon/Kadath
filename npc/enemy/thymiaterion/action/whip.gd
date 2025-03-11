extends "res://battle/action/simple_single_target.gd"

@export var hit: Hit

func execute(actor):
	var original_position = actor.global_position
	var target_position = Vector2(target.global_position.x, original_position.y)
	
	if target_position.x > original_position.x:
		actor.play_anim("walk_right_2")
	else:
		actor.play_anim("walk_left_2")
	
	await actor.move_to([target_position.x, target_position.y], 120)
	
	actor.play_anim("tongue_out")
	await get_tree().create_timer(0.53).timeout
	actor.play_anim("whip")
	
	
	await DoAll.new([
		func(): await get_tree().create_timer(0.95).timeout,
		func(): 
			await get_tree().create_timer(0.25).timeout
			await self.target.take_hit(actor, hit)
	]).execute()
	
	if target_position.x > original_position.x:
		actor.play_anim("walk_left_2")
	else:
		actor.play_anim("walk_right_2")
		
	await actor.move_to([original_position.x, original_position.y], 120)
	
	actor.play_anim("idle")
	self.reset()
