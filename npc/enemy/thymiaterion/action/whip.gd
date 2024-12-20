extends "res://battle/action/simple_single_target.gd"

func execute(actor):
	var original_position = actor.global_position
	var target_position = Vector2(target.global_position.x, original_position.y)
	
	if target_position.x > original_position.x:
		actor.play_anim("walk_right_2")
	else:
		actor.play_anim("walk_left_2")
	
	await actor.move_to([target_position.x, target_position.y], 120)
	
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor)
	actor.play_anim("whip")
	await get_tree().create_timer(1.8).timeout
	
	await DoAll.new([
		func(): await get_tree().create_timer(1.03).timeout,
		func(): await self.target.take_hit(hit)
	]).execute()
	
	if target_position.x > original_position.x:
		actor.play_anim("walk_left_2")
	else:
		actor.play_anim("walk_right_2")
		
	await actor.move_to([original_position.x, original_position.y], 200)
	
	actor.play_anim("idle")
	self.reset()
