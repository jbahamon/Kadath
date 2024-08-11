extends LocationRoom

const RESPONSE_YES = "yes"

@onready var animation_player = $AnimationPlayer
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
		await proxy.move_to(destination, proxy.walk_speed)

	proxy.set_orientation(Vector2.UP)
	proxy.play_anim("idle")

func attempt_chalice_interaction(proxy: PlayerProxy):
	var responses = await DialogueService.open_dialogue("chalice")

	if responses[0] == RESPONSE_YES:
		animation_player.play("drop_enemies")
		await animation_player.animation_finished
		await BattleService.start_battle(
			[$Ampoule1, $Ampoule2, $Ampoule3],
			false,
			PlayerProxy.ProxyMode.CUTSCENE
		)
		VarsService.set_flag("kadath.right_barrier", true)
		animation_player.play("chalice_activate")
		await animation_player.animation_finished
		await DialogueService.open_dialogue("after_chalice_battle")
		proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)

func solve_room():
	animation_player.play("chalice_activated")
	
