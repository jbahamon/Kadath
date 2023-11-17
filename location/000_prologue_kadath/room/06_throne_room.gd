extends LocationRoom

func fade_companion():
	var companion = $Peters
	var tween = get_tree().create_tween()
	tween.tween_property(companion, "modulate", Color(0,0,0,0), 0.5)
	
	await tween.finished
	
func darken_room():
	var tween = get_tree().create_tween()
	var method = func(color): self.set_layer_modulate(1, color); self.set_layer_modulate(0, color)
	tween.tween_method(method, Color.WHITE, Color.TRANSPARENT, 5)
	await tween.finished
	
func show_spooks():
	var spooks = $Spooks
	spooks.modulate = Color(0,0,0,0)
	var tween = get_tree().create_tween()
	tween.tween_property(spooks, "modulate", Color.WHITE, 0.5)
	
	await tween.finished
	
func show_title_card():
	SceneSwitcher.go_to_scene("res://ui/04_templates/other/demo_end.tscn")
