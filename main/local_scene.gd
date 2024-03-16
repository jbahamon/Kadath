extends Node2D
class_name LocalScene

func _ready() -> void:
	
	# These initializations don't depend on anything, so they can go in any order
	BattleService.initialize($BattleUILayer/BattleUI)
	CameraService.initialize(
		$SubViewportContainer/SubViewport/World/PlayerProxy/Camera2D,
		$SubViewportContainer/SubViewport
	)
	DialogService.initialize($DialogLayer/Dialog, $NarrationLayer)
	EntitiesService.initialize(
		$SubViewportContainer/SubViewport/World/PlayerProxy
	)
	EnvironmentService.initialize($SubViewportContainer/SubViewport/World)
	InputService.initialize(self)
	LayersService.initialize({
		"MIX": $SubViewportContainer/SubViewport/OverlayLayer/Mix,
		"ADD": $SubViewportContainer/SubViewport/OverlayLayer/Add,
		"CAMERA_BG": $SubViewportContainer/SubViewport/BGLayer/CameraBG
	})
	UIService.initialize($PopupLayer, $MenuLayer/MenuPopup, $MenuLayer/SavesPopup)
	
	# Here's a tricky part. We have to move to the first room, which will put the appropriate
	# nodes in the tree. This has to happen before the player proxy can be bound to the party or
	# whatever node is being controlled; otherwise there won't be a common parent to have a path 
	# between them.
	
	self.move_to_starting_room()
	self.bind_proxy()
	self.start_game()
	
func move_to_starting_room():
	if VarsService.loaded_slot >= 0:
		SavesService.load_game_data(VarsService.loaded_slot)
		VarsService.loaded_slot = -1
	else:
		# Note: move start_game to the above when doing the cutscene intro
		EnvironmentService.update_whereabouts(
			"000_prologue_kadath", 
			"05_boss_room",
			Vector2(0, 0), #Vector2.ZERO,
			Vector2.UP,
			false
		)
		
func bind_proxy():
	EntitiesService.bind_proxy()
	
func start_game():
	InputService.set_input_enabled(true)
	EntitiesService.get_proxy().set_mode(PlayerProxy.ProxyMode.GAMEPLAY)

func exit():
	BattleService.exit()
	CameraService.exit()
	DialogService.exit()
	EnvironmentService.exit()
	EntitiesService.exit()
	InputService.exit()
	LayersService.exit()
	UIService.exit()
