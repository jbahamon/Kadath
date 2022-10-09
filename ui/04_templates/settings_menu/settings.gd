extends PanelContainer

export var icon: Texture 

func grab_focus():
	return $SettingsMenu.grab_focus()


func release_focus():
	return $SettingsMenu.release_focus()
