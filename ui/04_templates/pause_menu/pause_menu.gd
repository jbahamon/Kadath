extends MarginContainer

onready var tabs = $PauseMenuTabs

enum MenuTabs {
	PARTY,
	ITEMS,
	SETTINGS
}
func initialize(party: Party):
	tabs.initialize(party)

func set_tab_disabled(tab: int, value: bool):
	tabs.set_tab_disabled(tab, value)
	
