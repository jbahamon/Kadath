extends Node2D
class_name LocalScene

func _ready() -> void:
	
	# These initializations don't depend on anything, so they can go in any order
	CutsceneService.initialize(
		$PopupLayer/CutscenePausePopup
	)
	BattleService.initialize(
		$BattleUILayer/BattleUI, 
		$PopupLayer/ScanResult
	)
	CameraService.initialize(
		$SubViewportContainer/SubViewport/World/PlayerProxy/Camera2D,
		$SubViewportContainer/SubViewport
	)
	DialogueService.initialize($DialogueLayer/Dialogue, $NarrationLayer)
	EntitiesService.initialize(
		$SubViewportContainer/SubViewport/World/PlayerProxy,
		$SubViewportContainer/SubViewport/World/InteractionIndicator,
		$SubViewportContainer/SubViewport/World/BattleTurnIndicator
		
	)
	EnvironmentService.initialize($SubViewportContainer/SubViewport/World)
	InputService.initialize(self)
	FXService.initialize(
		{
			"MIX": $SubViewportContainer/SubViewport/OverlayLayer/Mix,
			"ADD": $SubViewportContainer/SubViewport/OverlayLayer/Add,
			"CAMERA_BG": $SubViewportContainer/SubViewport/BGLayer/CameraBG,
			"CUTSCENE_PAUSE": $NarrationLayer/CutscenePauseBG
		}
	)
	UIService.initialize(
		$PopupLayer, 
		$MenuLayer/MenuPopup, 
		$MenuLayer/SavesPopup, 
		$UIControlPlayer, 
		$UINotificationPlayer
	)
	
	MusicService.initialize($BGMPlayer)
	InputService.input_enabled = true
	
	# Here's a tricky part. We have to move to the first room, which will put the appropriate
	# nodes in the tree. This has to happen before the player proxy can be bound to the party or
	# whatever node is being controlled; otherwise there won't be a common parent to have a path 
	# between them.
	await self.move_to_starting_room()
	EntitiesService.bind_proxy()
	
func move_to_starting_room():
	if VarsService.loaded_slot >= 0:
		SavesService.load_game_data(VarsService.loaded_slot)
		VarsService.loaded_slot = -1
	else:
		VarsService.scan_level = 2
		# Note: move start_game to the above when doing the cutscene intro
		await EnvironmentService.update_whereabouts(
			"000_prologue_kadath", #"999_tests", 
			"01_entrance",
			Vector2(0, 0),
			Vector2.UP,
			{
				"fade": false,
				"play_bgm": false,
				"end_proxy_state": PlayerProxy.ProxyMode.GAMEPLAY
			}
		)
	
func exit():
	BattleService.exit()
	CameraService.exit()
	DialogueService.exit()
	EnvironmentService.exit()
	EntitiesService.exit()
	InputService.exit()
	FXService.exit()
	UIService.exit()
