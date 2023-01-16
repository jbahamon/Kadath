extends BaseNPC

enum DialogNodes {
	BEFORE_QUEST = 1,
	IN_QUEST = 8,
	QUEST_DONE = 5,
	AFTER_AMULET_RECEIVED = 7,
}

func _ready():
	if PlayerVars.get_flag(PlayerVars.Flags.TUTORIAL_FINISHED):
		self.dialog_nid = DialogNodes.AFTER_AMULET_RECEIVED
	elif PlayerVars.get_flag(PlayerVars.Flags.TUTORIAL_STARTED):
		self.dialog_nid = DialogNodes.IN_QUEST
	else:
		self.dialog_nid = DialogNodes.BEFORE_QUEST
	
func on_player_interaction(player_proxy: PlayerProxy):
	if PlayerVars.get_flag(PlayerVars.Flags.TUTORIAL_STARTED):
		self.dialog_nid = DialogNodes.IN_QUEST
		
	if self.dialog_nid == DialogNodes.IN_QUEST and \
	 	PlayerVars.get_flag(PlayerVars.Flags.MENU_TUTORIAL_COMPLETED) and \
		PlayerVars.get_flag(PlayerVars.Flags.BATTLE_TUTORIAL_COMPLETED) and \
		PlayerVars.get_flag(PlayerVars.Flags.SAVE_TUTORIAL_COMPLETED) and \
		PlayerVars.get_flag(PlayerVars.Flags.EQUIPMENT_TUTORIAL_COMPLETED):
		
		self.dialog_nid = DialogNodes.QUEST_DONE
	
	.on_player_interaction(player_proxy)
	
	match self.dialog_nid:
		DialogNodes.BEFORE_QUEST:
			PlayerVars.set_flag(PlayerVars.Flags.TUTORIAL_STARTED, true)
			self.dialog_nid = DialogNodes.IN_QUEST
		DialogNodes.QUEST_DONE:
			PlayerVars.set_flag(PlayerVars.Flags.TUTORIAL_FINISHED, true)
			var inventory = player_proxy.get_inventory()
			if not inventory.has("amulet"):
				inventory.add("amulet")
			self.dialog_nid = DialogNodes.AFTER_AMULET_RECEIVED
		

func get_slot(_nid, _slots):
	
	if not PlayerVars.get_flag(PlayerVars.Flags.SAVE_TUTORIAL_COMPLETED):
		return 0
	elif not PlayerVars.get_flag(PlayerVars.Flags.EQUIPMENT_TUTORIAL_COMPLETED):
		return 1
	elif not PlayerVars.get_flag(PlayerVars.Flags.BATTLE_TUTORIAL_COMPLETED):
		return 2
	elif not PlayerVars.get_flag(PlayerVars.Flags.SAVE_TUTORIAL_COMPLETED):
		return 3
	else:
		return DialogNodes.QUEST_DONE
			
		

