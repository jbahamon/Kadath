extends BattleAction

@export var hit: Hit
@export var suck_sound: AudioStream
@export var chew_sound: AudioStream
@export var spit_sound: AudioStream

var targets = []

func reset():
	self.targets = []
	
func execute(actor):
	var target_list = self.targets[0].get_targets()
	self.hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, self.hit)
	
	await BattleService.announce(self.description, UIService.PROMPT_WAIT_TIME)
	actor.play_anim("open_mouth")
	FXService.play_sfx_at(suck_sound, actor.global_position)
	var target_info = self.targets[0].get_targets()	.map(func(target): return {
		"position": target.global_position,
		"z_index": target.z_index
	})
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)

	var target_position = actor.global_position + Vector2(0, -38)
	for target in target_list:
		target.z_index = actor.z_index + 1
		target.play_anim("hit")
		tween.tween_property(target, "global_position", target_position, 1.5)
		tween.tween_property(target, "scale", Vector2(0.5, 0.5), 1.5)
		
	await tween.finished
	for target in target_list:
		target.visible = false

	actor.play_anim("chew")
	await get_tree().create_timer(0.3).timeout
	FXService.play_sfx_at(chew_sound, actor.global_position)
	await get_tree().create_timer(0.6).timeout
	FXService.play_sfx_at(chew_sound, actor.global_position)
	await get_tree().create_timer(0.6).timeout
	FXService.play_sfx_at(chew_sound, actor.global_position)
	await get_tree().create_timer(0.6).timeout
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_parallel(true)
	actor.play_anim("open_mouth")
	FXService.play_sfx_at(spit_sound, actor.global_position)
	
	for i in range(target_list.size()):
		target_list[i].visible = true
		target_list[i].scale = Vector2.ONE
		tween.tween_property(target_list[i], "global_position:x", target_info[i]["position"].x, 0.8)
		tween.tween_property(target_list[i], "global_position:y", target_info[i]["position"].y, 0.8	).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	
	for i in range(target_list.size()):
		target_list[i].z_index = target_info[i]["z_index"]
	
	actor.play_anim("idle")
	 
	var hits = target_list.map(
		func(target): 
			return func(): 
				await target.take_hit(actor, hit)
				target.play_anim("battle_idle")
	)
	hits.append(FXService.env_shake(1.0, Vector2(0, 4), 0.5).shake_finished)
	await DoAll.new(hits).execute()
	
	self.reset()
