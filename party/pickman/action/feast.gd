extends "res://battle/action/simple_single_target.gd"

@export var normal_attack_factor = 0.5
@export var heal_factor = 0.75
@export var energy_gain_factor = 0.1
@export var hit: Hit
@export var heal_sound: AudioStream

var unlocking_ids = {
	"" : ""
}

func execute(actor):
	var original_position = actor.global_position
	await self.move_to_target(actor, target, 180, "run")
	actor.play_anim("feast")
	await get_tree().create_timer(0.4).timeout
	
	hit.base_damage = actor.battler.physical_attack * self.normal_attack_factor
	await self.target.take_hit(actor, hit)
	actor.play_anim("battle_idle")
	# For balance, we could make it so it heals less with each use. 
	# Like 0.8^n_usages and start from a big one.
	FXService.play_sfx_at(self.heal_sound, actor.global_position)
	await actor.heal(ceil(self.heal_factor * hit.effective_damage))
	await get_tree().create_timer(0.1).timeout
	await actor.recover_energy(ceil(self.energy_gain_factor * hit.effective_damage))
	
	actor.play_anim("jump_back")
	await actor.move_to([original_position.x, original_position.y], 180)
	actor.play_anim("battle_idle")
	# Unlock 
	
	var enemy_id = target.enemy_id
	if enemy_id in self.unlocking_ids:
		actor.unlock_skill(self.unlocking_ids[enemy_id])

	self.reset()
