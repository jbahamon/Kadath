extends Node

var scene: Node

var inputs_disabled = false

func initialize(init_scene: Node):
	self.scene = init_scene
	
func disable_inputs():
	var proxy = EntitiesService.get_proxy()
	var world = EnvironmentService.get_world()
	if not inputs_disabled: 
		scene.set_process_unhandled_input(false)
		proxy.set_process(false)
		proxy.set_physics_process(false)
		proxy.set_process_unhandled_input(false)
		world.set_process_unhandled_input(false)
		inputs_disabled = true
		return false
	else:
		return true
	
func enable_inputs():
	var proxy = EntitiesService.get_proxy()
	var world = EnvironmentService.get_world()
	if inputs_disabled:
		scene.set_process_unhandled_input(true)
		proxy.set_process(true)
		proxy.set_physics_process(true)
		proxy.set_process_unhandled_input(true)
		world.set_process_unhandled_input(true)
		inputs_disabled = false
		return true
	else:
		return false

func enter_menu_mode(menu) -> void:
	var proxy = EntitiesService.get_proxy()
	var world = EnvironmentService.get_world()
	
	proxy.set_process_unhandled_input(false)
	world.set_physics_process(false)
	world.set_process(false)
	world.set_process_unhandled_input(false)
	menu.set_process_unhandled_input(true)

func exit_menu_mode(menu) -> void:
	var proxy = EntitiesService.get_proxy()
	var world = EnvironmentService.get_world()
	
	proxy.set_process_unhandled_input(true)
	world.set_physics_process(true)
	world.set_process(true)
	world.set_process_unhandled_input(true)
	menu.set_process_unhandled_input(false)
