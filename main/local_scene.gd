extends Node2D
class_name LocalScene

func _ready() -> void:
	BattleService.initialize($BattleUILayer/BattleUI)
	CameraService.initialize(
		$SubViewportContainer/SubViewport/World/PlayerProxy/Camera2D,
		$SubViewportContainer/SubViewport
	)
	DialogService.initialize                                                                                                  ($DialogLayer/Dialog, $NarrationLayer)
	EntitiesService.initialize(
		$SubViewportContainer/SubViewport/World/PlayerProxy, 
		$SubViewportContainer/SubViewport/World/Party
	)
	EnvironmentService.initialize($SubViewportContainer/SubViewport/World)
	InputService.initialize(self)
	LayersService.initialize({
		"MIX": $SubViewportContainer/SubViewport/OverlayLayer/Mix,
		"ADD": $SubViewportContainer/SubViewport/OverlayLayer/Add,
		"CAMERA_BG": $SubViewportContainer/SubViewport/BGLayer/CameraBG
	})
	UIService.initialize($PopupLayer, $MenuLayer/MenuPopup, $MenuLayer/SavesPopup)
	
	if VarsService.loaded_slot >= 0:
		SavesService.load_game_data(VarsService.loaded_slot)
		VarsService.loaded_slot = -1
	else:
		EnvironmentService.update_whereabouts(
			"000_prologue_kadath", 
			"02_hub",
			Vector2(0, 86), #Vector2.ZERO,
			Vector2.UP,
			false
		)
