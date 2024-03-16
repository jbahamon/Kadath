extends PanelContainer

signal exit_submenu

@export var icon: Texture2D 

func on_grab_focus():
	$SettingsMenu.on_grab_focus()

func _on_settings_menu_exit():
	emit_signal("exit_submenu")
