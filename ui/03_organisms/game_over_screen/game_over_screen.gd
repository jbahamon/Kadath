extends MarginContainer

@onready var try_again: Button = $VBoxContainer/TryAgain
@onready var load_save: Button = $VBoxContainer/LoadSave
@onready var to_title: Button = $VBoxContainer/ToTitle

func _ready() -> void:
	self.try_again.hide()
	self.load_save.hide()
	self.to_title.grab_focus()
	InputService.enter_menu_mode()
	
func on_to_title_pressed():
	SceneSwitcher.load_scene("res://ui/04_templates/main_menu/main_menu.tscn")
	
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.BLACK, 0.5)
	await DoAll.new([
		SceneSwitcher.scene_loaded,
		tween.finished
	]).execute()
	
	SceneSwitcher.change_scene()
	
