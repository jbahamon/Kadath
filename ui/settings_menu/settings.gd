extends PanelContainer

export var icon: Texture 

func receive_focus():
	return $SettingsMenu.receive_focus()


func relinquish_focus():
	return $SettingsMenu.relinquish_focus()