extends "res://npc/lib/enemy.gd"

var blend_add_shader = preload("res://utils/material/blend_add.gdshader")
var boss_dissolve_shader = preload("res://utils/material/boss_dissolve.gdshader")

func die(mode: CutsceneInstruction.ExecutionMode):
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		await get_tree().create_timer(0.3).timeout
		
		var shine_material = ShaderMaterial.new()
		shine_material.shader = blend_add_shader
		shine_material.set_shader_parameter("add", Vector4(0.0, 0.0, 0.0, 0.0))
		self.material = shine_material
		
		var shine_tween = get_tree().create_tween()
		shine_tween.tween_property(shine_material, "shader_parameter/add", Vector4(1.0, 1.0, 1.0, 0.0), 1.5)
		await shine_tween.finished
		
		FXService.shake(self.anim, 3, Vector2(4, 0), 1.0, FXService.DecayMode.NONE)
		var dissolve_material = ShaderMaterial.new()
		dissolve_material.shader = boss_dissolve_shader
		dissolve_material.set_shader_parameter("add", Vector4(1.0, 1.0, 1.0, 0.0))
		dissolve_material.set_shader_parameter("alpha", 1.0)
		self.material = dissolve_material
		
		var dissolve_tween = get_tree().create_tween()
		dissolve_tween.tween_property(dissolve_material, "shader_parameter/add", Vector4(0.0, 0.0, 0.0, 0.0), 1.0)
		dissolve_tween.tween_interval(0.5)
		dissolve_tween.tween_property(dissolve_material, "shader_parameter/alpha", 0.0, 1.5)
		dissolve_tween.tween_interval(0.3)
		await dissolve_tween.finished
		
		
		
		
	self.queue_free()
