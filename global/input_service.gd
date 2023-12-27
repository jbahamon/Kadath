extends Node

var scene: Node

var input_enabled = true

func initialize(init_scene: Node):
	self.scene = init_scene

func is_input_enabled():
	return self.input_enabled
	
func set_input_enabled(value: bool):
	var world = EnvironmentService.get_world()
	self.scene.set_process_unhandled_input(value)
	world.set_process_unhandled_input(value)
	self.input_enabled = value

func enter_menu_mode(_menu) -> void:
	get_tree().paused = true
	
func exit_menu_mode(_menu) -> void:
	get_tree().paused = false
