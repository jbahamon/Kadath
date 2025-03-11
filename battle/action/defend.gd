extends BattleAction

var Defending = preload("res://battle/status_effect/defending.gd")
var defend_sound: AudioStream = preload("res://sound/fx/block/Defend - Leohpaz.wav")

func reset():
	pass
	
func get_next_parameter_signature():
	return null
	
func push_parameter(_parameter_name, _value):
	assert(false, "this action requires no parameters")
	
func pop_parameter() -> bool:
	return false
	
func execute(actor: Node):
	actor.play_anim("defend")
	await actor.get_tree().create_timer(0.5).timeout
	FXService.play_sfx_at(defend_sound, actor.global_position)
	actor.battler.status_effects.add(Defending.new())
	await actor.get_tree().create_timer(0.75).timeout
	actor.play_anim("battle_idle")
	
