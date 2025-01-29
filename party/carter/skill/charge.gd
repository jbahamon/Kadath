extends BattleAction

var Charged = preload("res://party/carter/status_effect/charged.gd")

@onready var particles = get_node("../../../ChargeParticles")

func reset():
	pass
	
func get_next_parameter_signature():
	return null
	
func push_parameter(_parameter_name, _value):
	assert(false, "this action requires no parameters")
	
func pop_parameter() -> bool:
	return false
	
func execute(actor):
	var prev_material = actor.material
	actor.material = highlight_material
	actor.play_anim("charge")
	particles.visible = true
	particles.emitting = true
	
	await actor.get_tree().create_timer(3.0).timeout
	actor.battler.status_effects.add(Charged.new())
	actor.play_anim("battle_idle")
	particles.visible = false
	particles.emitting = false
	actor.material = prev_material
