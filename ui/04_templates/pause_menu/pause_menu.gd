extends MarginContainer

@onready var tabs = $Container/PauseMenuTabs


func initialize():
	tabs.initialize()

func set_tab_disabled(tab: int, value: bool):
	tabs.set_tab_disabled(tab, value)

func _on_visibility_changed():
	if self.is_visible_in_tree():
		tabs.reset()
