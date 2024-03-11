extends LocationRoom

@onready var animation_player = $AnimationPlayer
func on_enter():
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
	EntitiesService.get_proxy().set_mode(PlayerProxy.ProxyMode.CUTSCENE)

	animation_player.play("boss_enter")
	await animation_player.animation_finished
	await CameraService.shake(1.0, Vector2(10, 32))
	
	await BattleService.start_battle(
		[$Boss],
		false,
		PlayerProxy.ProxyMode.GAMEPLAY
	)

func shake_camera():
	CameraService.shake()
