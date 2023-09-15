extends Node

var scene: Node

var input_enabled = true

func initialize(init_scene: Node):
	self.scene = init_scene

func is_input_enabled():
	return self.input_enabled
	
func set_input_enabled(value: bool):
	var proxy = EntitiesService.get_proxy()
	var world = EnvironmentService.get_world()
	self.scene.set_process_unhandled_input(value)
	world.set_process_unhandled_input(value)
	
	if value: 
		proxy.resume()
	else:
		proxy.pause()
	self.input_enabled = value

func enter_menu_mode(menu) -> void:
	var proxy = EntitiesService.get_proxy()
	var world = EnvironmentService.get_world()
	
	proxy.pause()
	world.set_physics_process(false)
	world.set_process(false)
	world.set_process_unhandled_input(false)
	menu.set_process_unhandled_input(true)

func exit_menu_mode(menu) -> void:
	var proxy = EntitiesService.get_proxy()
	var world = EnvironmentService.get_world()
	
	proxy.resume()
	world.set_physics_process(true)
	world.set_process(true)
	world.set_process_unhandled_input(true)
	menu.set_process_unhandled_input(false)
