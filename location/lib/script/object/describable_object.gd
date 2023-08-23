extends InteractableObject

@export var dialog_name: String = "test_message"
@export var dialog_nid: int = 1

func on_player_interaction(_proxy: PlayerProxy):
	super.on_player_interaction(_proxy)
	DialogService.open_dialog(self.dialog_name, self)
	
