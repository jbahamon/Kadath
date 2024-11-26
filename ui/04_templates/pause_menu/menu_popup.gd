extends PopupPanel

@onready var help_label = $PauseMenu/Container/PanelContainer/HBoxContainer/Help
@onready var controls_label = $PauseMenu/Container/PanelContainer/HBoxContainer/Controls

func _on_pause_menu_tabs_cancel():
	get_tree().paused = false
	hide()
	
