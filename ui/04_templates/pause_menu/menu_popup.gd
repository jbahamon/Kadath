extends PopupPanel

@onready var help_bar = $PauseMenu/Container/HelpBar

func _on_pause_menu_tabs_cancel():
	InputService.exit_menu_mode()
	hide()
	
