extends PanelContainer

signal exit_submenu

@export var icon: Texture2D 
@export var help_text: String
@export var controls_text: String

func on_grab_focus():
	$SettingsMenu.on_grab_focus()

func _on_settings_menu_exit():
	self.exit_submenu.emit()
