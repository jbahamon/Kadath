extends Node

var scene: Node

var input_enabled = false:
	set(value):
		UIService.set_process_unhandled_input(value)
		input_enabled = value

func initialize(init_scene: Node):
	self.scene = init_scene
	
func exit():
	self.scene = null

func enter_menu_mode() -> void:
	get_tree().paused = true
	
func exit_menu_mode() -> void:
	get_tree().paused = false
