extends PopupPanel

@onready var help_bar = $PauseMenu/Container/HelpBar


func _on_pause_menu_tabs_cancel():
	hide()
	
func _on_about_to_popup() -> void:
	UIService.help_bar = help_bar
