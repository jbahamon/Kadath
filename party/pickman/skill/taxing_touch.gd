extends "res://battle/action/simple_single_target.gd"

@export var damage_factor = 1.25
@export var delay = 100
@export var hit: Hit
	
func execute(actor):
	var original_position = actor.global_position
	actor.battler.spend_energy(self.energy_cost)
	
	hit.base_damage = actor.battler.physical_attack * self.damage_factor
	
	await self.move_to_target(actor, target, 180, "run")
	actor.play_anim("taxing_touch")
	
	BattleService.delay_actor(target, self.delay)
	
	await DoAll.new([
		func(): 
			await self.target.take_hit(actor, hit)
			await actor.get_tree().create_timer(0.3).timeout
			await target.battler.show_toast("Delayed!"),
		func():
			await actor.get_tree().create_timer(1.0).timeout
			actor.play_anim("jump_back")
			await actor.move_to([original_position.x, original_position.y], 220)
			actor.play_anim("battle_idle")
	]).execute()

	self.reset()
