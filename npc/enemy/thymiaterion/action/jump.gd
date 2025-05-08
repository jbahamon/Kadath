extends BattleAction

@export var hit: Hit
@export var bump_sound: AudioStream

var targets = []

func reset():
	self.targets = []
	
func execute(actor):
	self.hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, self.hit)
	
	actor.play_anim("jump")
	
	await get_tree().create_timer(1.0).timeout
	
	var shake_func = func (): 
		FXService.play_sfx_at(self.bump_sound, actor.position)
		await FXService.env_shake(1.0, Vector2(0, 8), 1.0).shake_finished
		actor.play_anim("idle")
		
	var hits = self.targets[0].get_targets().map(func(target): return func(): await target.take_hit(actor, hit))
	hits.append(shake_func)
	await DoAll.new(hits).execute()
	
	self.reset()
