extends LocationRoom
const CIRCUIT_LAYER = 3

@onready var chalice = $Chalice
var failures = 0

func setup():
	if VarsService.get_flag("kadath.left_barrier"):
		solve_room()
	
func _on_acolyte_touched(_proxy: PlayerProxy):
	failures += 1
	
	if failures < 4:
		CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/caught.cutscene")
	else:
		await CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/caught_final.cutscene")
		BattleService.start_mook_battle(false)

func _on_chalice_player_interaction(proxy: PlayerProxy):
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.set_input_enabled(false)
	await self.move_player_to_chalice(proxy)
	
	if VarsService.get_flag("kadath.left_barrier"):
		await DialogueService.open_dialogue("chalice_done")
	else:
		await self.interact_with_chalice(proxy)
	
	InputService.set_input_enabled(true)
	proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)

func move_player_to_chalice(proxy):
	if chalice.position.distance_squared_to(proxy.top_position) > 9:
		var destination = Vector2(proxy.position.x, chalice.position.y + proxy.height + 2)

		proxy.play_anim("walk")
		proxy.set_orientation(destination - proxy.position)
		await proxy.move_to(destination, proxy.walk_speed)
		
		destination = Vector2(chalice.position.x, proxy.position.y)
		proxy.set_orientation(destination - proxy.position)
		await proxy.move_to(destination, proxy.walk_speed)

func interact_with_chalice(_proxy: PlayerProxy):
	await DialogueService.open_dialogue("chalice")
	VarsService.set_flag("kadath.left_barrier", true)
	await EnvironmentService.fade_out()
	self.solve_room()
	await EnvironmentService.fade_in()
	await DialogueService.open_dialogue("after_chalice_activation")

func solve_room():
	$Chalice/AnimatedSprite2D.play("full")
	self.set_layer_enabled(CIRCUIT_LAYER, true)
	
	# Pending: call this from cutscene?
	var acolytes = [
		get_node_or_null("LeftAcolyte1"), 
		get_node_or_null("LeftAcolyte2"), 
		get_node_or_null("RightAcolyte1"),
		get_node_or_null("RightAcolyte2")
	]
	for acolyte in acolytes:
		if acolyte != null:
			acolyte.queue_free()
	
	$AltarAcolyte1.frame_coords = Vector2(0, 6)
	$AltarAcolyte2.frame_coords = Vector2(0, 6)
