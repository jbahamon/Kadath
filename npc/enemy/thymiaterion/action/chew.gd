extends BattleAction

@export var hit: Hit
@export var chew_sound: AudioStream
var targets = []

func reset():
	self.targets = []
	
func execute(actor):
	await BattleService.announce(self.description, UIService.PROMPT_WAIT_TIME)
	actor.play_anim("open_mouth")
	var target_info = self.targets.map(func(target): return {
		"position": target.global_position,
		"z_index": target.z_index
	})
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)

	var target_position = actor.global_position + Vector2(0, -38)
	for target in targets:
		target.z_index = actor.z_index + 1
		target.play_anim("hit")
		tween.tween_property(target, "global_position", target_position, 1.5)
		tween.tween_property(target, "scale", Vector2(0.5, 0.5), 1.5)
		
	await tween.finished
	for target in targets:
		target.visible = false

	actor.play_anim("chew")
	FXService.play_sfx(chew_sound)
	await get_tree().create_timer(0.7).timeout
	FXService.play_sfx(chew_sound)
	await get_tree().create_timer(0.7).timeout
	FXService.play_sfx(chew_sound)
	await get_tree().create_timer(0.7).timeout
	
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_parallel(true)
	actor.play_anim("open_mouth")
	
	for i in range(targets.size()):
		targets[i].visible = true
		targets[i].scale = Vector2.ONE
		tween.tween_property(targets[i], "global_position:x", target_info[i]["position"].x, 0.8)
		tween.tween_property(targets[i], "global_position:y", target_info[i]["position"].y, 0.8	).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	
	for i in range(targets.size()):
		targets[i].z_index = target_info[i]["z_index"]
	
	actor.play_anim("idle")
	
	var shake_func = func (): 
		await FXService.env_shake(1.0, Vector2(0, 4), 0.5).shake_finished
	var hits = self.targets.map(
		func(target): 
			return func(): 
				await target.take_hit(actor, hit)
				target.play_anim("battle_idle")
	)
	hits.append(shake_func)
	await DoAll.new(hits).execute()
	
	self.reset()
