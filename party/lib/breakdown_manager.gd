extends Node2D

var breakdown_sound = preload("res://sound/fx/status/Breakdown - Diablo Luna.wav")
var recovery_sound = preload("res://sound/fx/heal/Breakdown Recovery - Leohpaz.wav")

@onready var breakdown_ai = $AI
@onready var old_ai = null

func start():
	var parent = self.get_parent()
	await BattleService.prompt("The situation is too much for %s..." % parent.display_name)
	await DoAll.new([
		func(): await parent.show_toast("Breakdown!", Color.BROWN),
		func(): await FXService.play_sfx_at(self.breakdown_sound, parent.global_position).finished
	]).execute()
	
	self.old_ai = parent.battler.ai
	parent.battler.ai = self.breakdown_ai
	
func stop(battle_ended):
	var parent = get_parent()
	
	if not battle_ended:
		await DoAll.new([
			func(): await parent.show_toast("Stability regained!"),
			func(): await FXService.play_sfx_at(self.recovery_sound, parent.global_position).finished
		]).execute()
	
	parent.battler.ai = self.old_ai
	self.old_ai = null
	parent.battler.energy = max(1, parent.battler.energy)
