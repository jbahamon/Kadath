extends LocationRoom

@export var found_sound: AudioStream
@export var teleport_sound: AudioStream
@export var slash_sound: AudioStream
@export var bridge_sound: AudioStream
@onready var circuit_layer = $Circuit
@onready var chalice = $Chalice
var failures = 0

const RESPONSE_YES = "yes"

func setup():
	if VarsService.get_flag("kadath.left_barrier"):
		solve_room()
	
func _on_acolyte_touched(_proxy: PlayerProxy):
	failures += 1
	FXService.play_sfx(self.found_sound)
	if failures < 3:
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
		await proxy.move_to([destination.x, destination.y], proxy.walk_speed)
		
		destination = Vector2(chalice.position.x, proxy.position.y)
		proxy.set_orientation(destination - proxy.position)
		await proxy.move_to([destination.x, destination.y], proxy.walk_speed)
	proxy.set_orientation(Vector2.UP)
	proxy.play_anim("idle")
	
func interact_with_chalice(proxy: PlayerProxy):
	var responses = await DialogueService.open_dialogue("chalice")
	
	
	if responses[0] == RESPONSE_YES:
		EntitiesService.party.set_physics_process(false)
		await proxy.play_anim("interact")
		await get_tree().create_timer(1.0).timeout
		await proxy.play_anim("idle")
		await get_tree().physics_frame
		EntitiesService.party.clear_movement_buffers()
		EntitiesService.party.set_physics_process(true)
		VarsService.set_flag("kadath.left_barrier", true)
		await EnvironmentService.fade_out()
		await get_tree().create_timer(0.2).timeout
		await FXService.play_sfx_at(self.slash_sound, Vector2(0,0)).finished
		await get_tree().create_timer(0.5).timeout
		self.solve_room()
		await EnvironmentService.fade_in()
		await FXService.play_sfx(self.bridge_sound).finished
		await DialogueService.open_dialogue("after_chalice_activation")
	else:
		EntitiesService.party.set_physics_process(true)
		
func solve_room():
	$Chalice/AnimatedSprite2D.play("full")
	self.circuit_layer.enabled = true

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
	
	$Altar/DescriptionArea/CollisionShape2D.disabled = false
	$Altar2/DescriptionArea/CollisionShape2D.disabled = false
