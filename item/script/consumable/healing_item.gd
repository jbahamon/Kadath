extends InventoryItem

class_name HealingItem

var recovery_sound = preload("res://sound/fx/recovery/Default - ReincarnatedEchoes.wav")

enum RecoveryMode {
	ABSOLUTE,
	PERCENTAGE
}

@export var recovery_mode: RecoveryMode = RecoveryMode.ABSOLUTE
@export var energy_recovery_mode: RecoveryMode = RecoveryMode.ABSOLUTE
@export var health: int = 0
@export var energy: int = 0
@export var status_effects: Array[String] = []
@export var battle_offset: Vector2
@export var battle_fx: SpriteFrames
@export var battle_fx_duration = -1.0

func use(targets: Array):
	
	FXService.play_sfx(recovery_sound)
	
	if self.health != 0:
		var lambdas = []
		for target in targets:
			var recovery = self.health if self.recovery_mode == RecoveryMode.ABSOLUTE else int(round(target.health * self.health / 100.0))
			target.heal(recovery)
			lambdas.append(
				func (): await target.show_toast(str(recovery), Color.LIGHT_GREEN)
			)
		await DoAll.new(lambdas).execute()
	
	if self.energy != 0:
		var lambdas = []
		for target in targets:
			var recovery = self.energy if self.recovery_mode == RecoveryMode.ABSOLUTE else int(round(target.energy * self.energy / 100.0))
			target.recover_energy(recovery)
			lambdas.append(
				func ():
					await target.show_toast(str(recovery), Color.LIGHT_SKY_BLUE)
			)
		await DoAll.new(lambdas).execute()

	return true

func use_in_battle(targets: Array):
	var lambdas = []
	
	if targets.size() > 1:
		FXService.play_sfx(recovery_sound)
	else:
		FXService.play_sfx_at(recovery_sound, targets[0].global_position)
	
	for target in targets:
		lambdas.append(
			func (): 
				var orientation = target.current_orientation
				target.set_orientation(Vector2.DOWN)
				target.play_anim("spin")
				FXService.play_gfx_at(
					self.battle_fx, 
					target.global_position, 
					self.battle_offset, 
					self.battle_fx_duration
				)
				await target.get_tree().create_timer(0.75).timeout
				target.play_anim("idle")
				# await show_effects
				for status_effect in self.status_effects: 
					target.battler.status_effects.remove(status_effect)
			
				if self.health != 0:
					var recovery = self.health if self.recovery_mode == RecoveryMode.ABSOLUTE else int(round(target.health * self.health / 100.0))
					await target.heal(recovery)
				
				if self.energy != 0:
					var energy_recovery = self.energy if self.energy_recovery_mode == RecoveryMode.ABSOLUTE else int(round(target.energy * self.energy / 100.0))
					await target.recover_energy(energy_recovery)
				target.set_orientation(orientation)
				target.play_anim("battle_idle")
				
		)
		
		await DoAll.new(lambdas).execute()

	return true
