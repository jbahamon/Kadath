extends LocationRoom

@onready var animation_player = $AnimationPlayer
func setup():
	if VarsService.get_flag("kadath.boss_defeated"):
		$BossTrigger.monitoring = false
	
func _on_north_gate_body_entered(body):
	if not body is PlayerProxy:
		return
	CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/end.cutscene")


func _on_boss_trigger_body_entered(body):
	if not body is PlayerProxy:
		return
	$BossTrigger.set_deferred("monitoring", false)
	InputService.set_input_enabled(false)
	
	var proxy = EntitiesService.get_proxy()
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	proxy.play_anim("idle")

	animation_player.play("boss_enter")
	await animation_player.animation_finished
	await CameraService.shake(CutsceneInstruction.ExecutionMode.PLAY, 1.0, Vector2(10, 32))
	InputService.set_input_enabled(true)
	await BattleService.start_battle(
		[$Boss],
		false,
		PlayerProxy.ProxyMode.GAMEPLAY
	)

