extends BaseNPC

const flag = "intro_traveler"

enum DialogNodes {
	TO_TRAVELER = 2,
	TO_ARDEN = 8,
}

func on_player_interaction(player_proxy: PlayerProxy):
	if VarsService.get_flag(flag):
		self.dialog_nid = DialogNodes.TO_ARDEN
	else:
		self.dialog_nid = DialogNodes.TO_TRAVELER
	
	super.on_player_interaction(player_proxy)
