extends LocationRoom

@export var fall_sound: AudioStream

@onready var animation_player = $AnimationPlayer
func setup():
	if VarsService.get_flag("kadath.boss_defeated"):
		$BossTrigger.monitoring = false
	
func _on_north_gate_body_entered(body):
	if not body is PlayerProxy:
		return
	CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/end.txt")


func _on_boss_trigger_body_entered(body):
	if not body is PlayerProxy:
		return
	$BossTrigger.set_deferred("monitoring", false)
	InputService.input_enabled = false
	
	var proxy = EntitiesService.proxy
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	proxy.play_anim("idle")

	animation_player.play("boss_enter")
	await animation_player.animation_finished
	await FXService.env_shake(1.0, Vector2(10, 32), 1.0).shake_finished
	InputService.input_enabled = true
	await BattleService.start_battle(
		[$Thymiaterion],
		{
			"escapable": false,
			"end_proxy_mode": PlayerProxy.ProxyMode.GAMEPLAY,
			"bgm": load("res://sound/music/xDeviruchi/Decisive Battle 1 - Don't Be Afraid.ogg")
		},
	)

func play_fall_sound():
	FXService.play_sfx_at(self.fall_sound, $Thymiaterion.global_position)
