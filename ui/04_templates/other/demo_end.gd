extends CanvasLayer

func _ready():
	self.set_process_unhandled_key_input(false)
	var timer = get_tree().create_timer(2.0)
	await timer.timeout
	$Prompt.visible = true
	self.set_process_unhandled_key_input(true)
	
	
func _unhandled_key_input(event):
	self.set_process_unhandled_key_input(false)
	SceneSwitcher.go_to_scene("res://ui/04_templates/main_menu/main_menu.tscn")
	
