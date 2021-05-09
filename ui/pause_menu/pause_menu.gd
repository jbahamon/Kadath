extends MarginContainer

onready var tabs = $PauseMenuTabs

func initialize(party: Party):
	tabs.initialize(party)
	
