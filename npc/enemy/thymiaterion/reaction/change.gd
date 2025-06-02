extends Reaction

var scream_sound = preload("res://sound/fx/scream/High Pitched - KronBits.wav")
var change_material: ShaderMaterial

func _init(material: Material) -> void:
	self.change_material = material
	
func is_triggered_by(actor, _hit, _actors):
	return (
		not actor.battler.ai.second_phase and 
		actor.battler.health < floor(0.7 * actor.battler.stats.max_health)
	)

func execute(actor, _actors):
	actor.battler.ai.second_phase = true
	actor.enemy_info = "Avoid hitting it when it's in its counterattack stance."
	actor.battler.ai.turn_counter = 0
	
	actor.battler.ai.remove_reaction(self)
	actor.material = change_material
	var tween: Tween = actor.get_tree().create_tween()
	tween.tween_method(func(c): self.change_material.set("shader_parameter/add", c), Color(Color.BLACK, 0.0), Color.TRANSPARENT, 1.0)
	FXService.env_shake(2.0, Vector2(16, 16), 1.0)
	FXService.play_sfx_at(self.scream_sound, actor.global_position)
	await tween.finished
	actor.play_anim("morph")
	tween = actor.get_tree().create_tween()
	tween.tween_method(func(c): self.change_material.set("shader_parameter/add", c), Color.TRANSPARENT, Color(Color.BLACK, 0.0), 1.0)
	await tween.finished
	actor.material = null
	actor.play_anim("idle")
	
	
