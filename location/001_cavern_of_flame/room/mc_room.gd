extends LocationRoom

var tween: Tween

func on_enter():
	if not VarsService.get_flag('cavern_of_flame.mc_room.intro'):
		self.swap_team()
		VarsService.set_flag('cavern_of_flame.mc_room.intro', true)
		await CutsceneService.play_cutscene_from_file('res://location/001_cavern_of_flame/cutscene/intro1.txt')
		await self.name_mc()
		await CutsceneService.play_cutscene_from_file('res://location/001_cavern_of_flame/cutscene/intro2.txt')
		EntitiesService.proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)
	
func spawn_monk():
	var scene: PackedScene = load("res://npc/lib/simple_human_npc.tscn")
	var npc = scene.instantiate()
	npc.name = "WakeMonk"
	self.add_child(npc)
	npc.global_position = Vector2(80, 0)
	npc.set_orientation(Vector2(-1, 0))

func name_mc():
	return
	var scene: PackedScene # = load("...")
	var popup = scene.instantiate()
	UIService.popup_layer.add_child(popup)
	
	# TODO avoid injection here
	var name = await popup.close
	VarsService.set_string("mc_name", name)

func fade_monk(mode: CutsceneInstruction.ExecutionMode):
	var monk = $WakeMonk

	if monk == null:
		return
	
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.tween = get_tree().create_tween()
		self.tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		self.tween.tween_property(monk, "modulate", Color.TRANSPARENT, 0.5)
		await self.tween.finished
		
	monk.queue_free()
		
	
func skip_call(function_name: String):
	if self.tween == null:
		return

	self.tween.finished.emit()
	self.tween.kill()
	
func swap_team():
	for party_member in EntitiesService.party.get_unlocked_characters():
		if party_member.id != PartyMember.Id.ALEX:
			EntitiesService.party.set_unlocked(party_member.id, false)
			
	EntitiesService.party.set_unlocked(PartyMember.Id.ALEX, true)
		
