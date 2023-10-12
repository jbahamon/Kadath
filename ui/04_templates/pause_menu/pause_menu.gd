extends MarginContainer

@onready var tabs = $PauseMenuTabs

func initialize(party: Party):
	tabs.initialize(party)

func set_tab_disabled(tab: int, value: bool):
	tabs.set_tab_disabled(tab, value)

func _on_visibility_changed():
	tabs.reset()
