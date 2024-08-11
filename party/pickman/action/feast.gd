extends "res://battle/action/simple_single_target.gd"

@export var normal_attack_factor = 0.75
@export var heal_factor = 0.5
@export var energy_gain_factor = 0.1

var unlocking_ids = {
	"" : ""
}

func execute(actor):
	var hit = Hit.new()
	hit.type = Hit.Element.PHYSICAL
	hit.base_damage = self.get_standard_attack_damage(actor) * self.normal_attack_factor
	
	var enemy_id = self.target.enemy_id
	var damage = await self.target.take_hit(hit)
	
	# For balance, we could make it so it heals less with each use. 
	# Like 0.8^n_usages and start from a big one.
	await actor.heal(ceil(self.heal_factor * damage))
	await get_tree().create_timer(0.1).timeout
	await actor.recover_energy(ceil(self.energy_gain_factor * damage))
	
	# Unlock 
	if enemy_id in self.unlocking_ids:
		actor.unlock_skill(self.unlocking_ids[enemy_id])

	self.reset()
