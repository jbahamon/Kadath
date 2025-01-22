extends "res://battle/action/simple_single_target.gd"

@export var normal_attack_factor = 1.0
@export var hit: Hit
	
func execute(actor):
	# walk to target
	var original_position = actor.global_position
	var center = target.battler.get_hitspot("Center")
	var target_position = target.global_position + Vector2(0, 2)
	
	actor.set_orientation(actor.global_position.direction_to(target_position))
	actor.play_anim("idle")
	actor.z_index = 3
	
	var tween: Tween = actor.get_tree().create_tween()
	
	tween.tween_property(actor.get_node("Anim"), "position", Vector2(0, center.y - target_position.y), 0.75)
	await DoAll.new([
		func (): await actor.move_to([target_position.x, target_position.y + 1], 140),
		func (): await tween.finished
	]).execute()
	
	actor.play_anim("clamp")
	hit.base_damage = actor.battler.physical_attack * self.normal_attack_factor
	await self.target.take_hit(actor, hit)
	actor.play_anim("idle")
	
	tween = actor.get_tree().create_tween()
	tween.tween_property(actor.get_node("Anim"), "position", Vector2(0, 0), 0.75)
	
	await DoAll.new([
		func (): await tween.finished,
		func (): await actor.move_to([original_position.x, original_position.y], 140)
	]).execute()
	actor.z_index = 0
	
	self.reset()
