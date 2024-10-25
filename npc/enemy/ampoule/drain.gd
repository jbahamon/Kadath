extends "res://battle/action/simple_single_target.gd"

@export var normal_attack_factor = 0.75
@export var heal_factor = 1
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
	var y_offset = center.y - target_position.y
	tween.tween_property(actor.get_node("Anim"), "position", Vector2(0, center.y - target_position.y), 0.75)
	await DoAll.new([
		func (): await actor.move_to([target_position.x, target_position.y + 1], 140),
		func (): await tween.finished
	]).execute()
	
	actor.play_anim("grab")
	hit.base_damage = self.get_standard_attack_damage(actor)  * self.normal_attack_factor
	
	var idle_anim = "battle_idle" if target.has_anim("battle_idle") else "idle"
	var tree = actor.get_tree()
	
	await DoAll.new([
		func(): 
			await tree.create_timer(0.3).timeout
			self.target.play_anim("hit"),
		func():
			await self.target.take_hit(hit)
	]).execute()

	await tree.create_timer(0.3).timeout
	actor.battler.toast_offset.y += y_offset
	await actor.heal(ceil(self.heal_factor * hit.effective_damage))
	
	self.target.play_anim(idle_anim)
	actor.play_anim("idle")
	
	tween = actor.get_tree().create_tween()
	tween.tween_property(actor.get_node("Anim"), "position", Vector2(0, 0), 0.75)
	
	await DoAll.new([
		func (): await tween.finished,
		func (): await actor.move_to([original_position.x, original_position.y], 140)
	]).execute()
	actor.z_index = 0
	actor.battler.toast_offset.y -= y_offset
	self.reset()
