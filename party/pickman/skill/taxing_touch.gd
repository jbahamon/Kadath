extends "res://battle/action/simple_single_target.gd"

@export var delay = 100
@export var hit: Hit
	
func execute(actor):
	var original_position = actor.global_position
	actor.battler.spend_energy(self.energy_cost)
	
	hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, hit)
	
	await self.move_to_target(actor, target, 180, "run")
	actor.play_anim("taxing_touch")
	
	await DoAll.new([
		func(): 
			await self.target.take_hit(actor, hit)
			await actor.get_tree().create_timer(0.3).timeout
			BattleService.delay_actor(target, self.delay)
			await target.battler.show_toast("Delayed!"),
		func():
			await actor.get_tree().create_timer(1.0).timeout
			actor.play_anim("jump_back")
			await actor.move_to([original_position.x, original_position.y], 220)
			actor.play_anim("battle_idle")
	]).execute()

	self.reset()
