extends Node

var scene: Node

var input_enabled = false

func initialize(init_scene: Node):
	self.scene = init_scene
	
func exit():
	self.scene = null
	
func is_input_enabled():
	return self.input_enabled
	
func set_input_enabled(value: bool):
	UIService.set_process_unhandled_input(value)
	self.input_enabled = value

func enter_menu_mode() -> void:
	get_tree().paused = true
	
func exit_menu_mode() -> void:
	get_tree().paused = false
