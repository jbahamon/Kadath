extends LocationRoom

@export var found_sound: AudioStream
@export var teleport_sound: AudioStream
@export var slash_sound: AudioStream
@onready var circuit_layer = $Circuit
@onready var chalice = $Chalice
var failures = 0

func setup():
	if VarsService.get_flag("kadath.left_barrier"):
		solve_room()
	
func _on_acolyte_touched(_proxy: PlayerProxy):
	failures += 1
	FXService.play_sfx(self.found_sound)
	if failures < 4:
		CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/caught.txt")
	else:
		await CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/caught_final.txt")
		BattleService.start_mook_battle({
			"escapable": false
		})

func _on_chalice_player_interaction(proxy: PlayerProxy):
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.input_enabled = false
	await self.move_player_to_chalice(proxy)
	
	if VarsService.get_flag("kadath.left_barrier"):
		await DialogueService.open_dialogue("chalice_done")
	else:
		await self.interact_with_chalice(proxy)
	
	InputService.input_enabled = true
	proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)
	
func play_teleport_sound():
	FXService.play_sfx(self.teleport_sound)

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
	FXService.play_sfx_at(self.slash_sound, Vector2(0,0))
	await FXService.spatial_sfx_player.finished
	await get_tree().create_timer(0.5).timeout
	self.solve_room()
	await EnvironmentService.fade_in()
	await DialogueService.open_dialogue("after_chalice_activation")

func solve_room():
	$Chalice/AnimatedSprite2D.play("full")
	self.circuit_layer.enabled = true
	
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
