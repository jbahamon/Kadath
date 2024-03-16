extends LocationRoom

@onready var animation_player = $AnimationPlayer
@onready var paten = $Paten

func on_enter():
	if VarsService.get_flag("kadath.left_barrier"):
		solve_room()
	
func _on_cultist_touched(_proxy: PlayerProxy):
	CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/caught.cutscene")

func _on_paten_player_interaction(proxy: PlayerProxy):
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.set_input_enabled(false)
	await self.move_player_to_paten(proxy)
	
	if VarsService.get_flag("kadath.left_barrier"):
		await DialogService.open_dialog("paten_done")
	else:
		await self.interact_with_paten(proxy)
	
	InputService.set_input_enabled(true)
	proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)

func move_player_to_paten(proxy):
	if paten.position.distance_squared_to(proxy.top_position) > 9:
		var destination = Vector2(proxy.position.x, paten.position.y + proxy.height + 2)

		proxy.play_anim("walk")
		proxy.set_orientation(destination - proxy.position)
		await proxy.move_to(destination, proxy.walk_speed)
		
		destination = Vector2(paten.position.x, proxy.position.y)
		proxy.set_orientation(destination - proxy.position)
		await proxy.move_to(destination, proxy.walk_speed)

func interact_with_paten(proxy: PlayerProxy):
	await DialogService.open_dialog("paten")

	VarsService.set_flag("kadath.left_barrier", true)
	animation_player.play("paten_activate")
	await animation_player.animation_finished
	solve_room()
	await DialogService.open_dialog("after_paten_activation")

func solve_room():
	
	$LeftSentry1.queue_free()
	$LeftSentry2.queue_free()
	$RightSentry1.queue_free()
	$RightSentry2.queue_free()
