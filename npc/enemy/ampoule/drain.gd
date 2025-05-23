extends "res://battle/action/simple_single_target.gd"

const blurb = "Phlebotomy"
@export var heal_factor = 1
@export var hit: Hit
@export var drain_sound: AudioStream
@export var heal_sound: AudioStream

func execute(actor):
	self.hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, self.hit)
	
	# walk to target
	BattleService.announce(self.blurb)
	var original_position = actor.global_position
	var center = target.battler.get_hitspot("Center")
	var target_position = target.global_position + Vector2(0, 2)
	actor.z_index = 3
	
	var tween: Tween = actor.get_tree().create_tween()
	var y_offset = center.y - target_position.y
	tween.tween_property(actor.get_node("Anim"), "position", Vector2(0, center.y - target_position.y), 0.75)
	
	await DoAll.new([
		func (): await self.move_to_target(actor, target_position, 140, "idle"),
		tween.finished
	]).execute()
	
	actor.play_anim("grab")
	
	var idle_anim = "battle_idle" if target.has_anim("battle_idle") else "idle"
	var tree = actor.get_tree()
	
	await DoAll.new([
		func(): 
			await tree.create_timer(0.3).timeout
			self.target.play_anim("hit")
			await tree.create_timer(0.1).timeout
			FXService.play_sfx_at(self.drain_sound, actor.position),
		func():
			await self.target.take_hit(actor, hit)
	]).execute()

	await tree.create_timer(0.3).timeout
	actor.battler.toast_offset.y += y_offset
	FXService.play_sfx_at(self.heal_sound, actor.global_position)
	await actor.heal(ceil(self.heal_factor * hit.effective_damage))
	BattleService.announce("")
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
