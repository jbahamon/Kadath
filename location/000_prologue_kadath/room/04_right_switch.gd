extends LocationRoom

const CIRCUIT_LAYER = 3

const RESPONSE_YES = "yes"

@onready var chalice = $Chalice

func setup():
	if VarsService.get_flag("kadath.right_barrier"):
		solve_room()
		
func _on_chalice_player_interaction(proxy: PlayerProxy):
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.set_input_enabled(false)
	await self.move_player_to_chalice(proxy)
	
	if VarsService.get_flag("kadath.right_barrier"):
		await DialogueService.open_dialogue("chalice_right_done")
		
	else:
		await self.attempt_chalice_interaction(proxy)
	
	InputService.set_input_enabled(true)
	proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)

func move_player_to_chalice(proxy):
	if chalice.position.distance_squared_to(proxy.top_position) > 9:
		
		var destination = [proxy.position.x, chalice.position.y + proxy.height + 2]

		proxy.play_anim("walk")
		proxy.set_orientation(Vector2(destination[0], destination[1]) - proxy.position)
		await proxy.move_to(destination, proxy.walk_speed)
		
		destination = Vector2(chalice.position.x, proxy.position.y)
		proxy.set_orientation(destination - proxy.position)
		await proxy.move_to([destination.x, destination.y], proxy.walk_speed)

	proxy.set_orientation(Vector2.UP)
	proxy.play_anim("idle")

func attempt_chalice_interaction(proxy: PlayerProxy):
	var responses = await DialogueService.open_dialogue("chalice")

	if responses[0] == RESPONSE_YES:
		await proxy.play_anim("interact")
		await get_tree().create_timer(0.6).timeout
		await proxy.play_anim("idle")
		await self.drop_enemies()
		await BattleService.start_battle(
			[$Ampoule1, $Ampoule2, $Ampoule3],
			false,
			PlayerProxy.ProxyMode.CUTSCENE,
		)
		VarsService.set_flag("kadath.right_barrier", true)
		await EnvironmentService.fade_out()
		self.solve_room()
		await EnvironmentService.fade_in()
		await DialogueService.open_dialogue("after_chalice_activation")
		proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)

func drop_enemies():
	for ampoule in [$Ampoule1, $Ampoule2, $Ampoule3,]:
		await get_tree().create_timer(0.5).timeout
		ampoule.visible = true
		await get_tree().create_tween().tween_property(ampoule.get_node("Anim/Sprite2D"), "offset:y", -60, 0.9).finished

func solve_room():
	$Chalice/Sprite2D.play("full")
	self.set_layer_enabled(CIRCUIT_LAYER, true)
