extends TabContainer

func _ready():
	
	# TODO: these tabs are disabled for now.
	set_tab_disabled(0, true)
	set_tab_disabled(1, true)
	current_tab = 2
