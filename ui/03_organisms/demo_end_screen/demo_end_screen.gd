extends MarginContainer

@onready var to_title: Button = $VBoxContainer/ToTitle

func _ready() -> void:
	self.to_title.grab_focus()
	
func on_to_title_pressed():
	SceneSwitcher.load_scene("res://ui/04_templates/main_menu/main_menu.tscn")
	
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	await DoAll.new([
		SceneSwitcher.scene_loaded,
		tween.finished
	]).execute()
	
	SceneSwitcher.switch_scene()
	
