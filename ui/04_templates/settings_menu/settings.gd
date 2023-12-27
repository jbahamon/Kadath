extends PanelContainer

@export var icon: Texture2D 

func on_grab_focus():
	$SettingsMenu.on_grab_focus()


func on_release_focus():
	return $SettingsMenu.on_release_focus()
