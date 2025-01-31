extends BaseNPC

enum DialogNodes {
	BEFORE_QUEST = 1,
	IN_QUEST = 8,
	QUEST_DONE = 5,
	AFTER_AMULET_RECEIVED = 7,
}

func _ready():
	if VarsService.get_flag(VarsService.Flags.TUTORIAL_FINISHED):
		self.dialog_nid = DialogNodes.AFTER_AMULET_RECEIVED
	elif VarsService.get_flag(VarsService.Flags.TUTORIAL_STARTED):
		self.dialog_nid = DialogNodes.IN_QUEST
	else:
		self.dialog_nid = DialogNodes.BEFORE_QUEST
	
func on_player_interaction(player_proxy: PlayerProxy):
	if VarsService.get_flag(VarsService.Flags.TUTORIAL_STARTED):
		self.dialog_nid = DialogNodes.IN_QUEST
		
	if self.dialog_nid == DialogNodes.IN_QUEST and \
		VarsService.get_flag(VarsService.Flags.MENU_TUTORIAL_COMPLETED) and \
		VarsService.get_flag(VarsService.Flags.BATTLE_TUTORIAL_COMPLETED) and \
		VarsService.get_flag(VarsService.Flags.SAVE_TUTORIAL_COMPLETED) and \
		VarsService.get_flag(VarsService.Flags.EQUIPMENT_TUTORIAL_COMPLETED):
		
		self.dialog_nid = DialogNodes.QUEST_DONE
	
	super.on_player_interaction(player_proxy)
	
	match self.dialog_nid:
		DialogNodes.BEFORE_QUEST:
			VarsService.set_flag(VarsService.Flags.TUTORIAL_STARTED, true)
			self.dialog_nid = DialogNodes.IN_QUEST
		DialogNodes.QUEST_DONE:
			VarsService.set_flag(VarsService.Flags.TUTORIAL_FINISHED, true)
			var inventory = EntitiesService.party.get_inventory()
			if not inventory.has("amulet"):
				inventory.add("amulet")
			self.dialog_nid = DialogNodes.AFTER_AMULET_RECEIVED
		

func get_slot(_nid, _slots):
	
	if not VarsService.get_flag(VarsService.Flags.SAVE_TUTORIAL_COMPLETED):
		return 0
	elif not VarsService.get_flag(VarsService.Flags.EQUIPMENT_TUTORIAL_COMPLETED):
		return 1
	elif not VarsService.get_flag(VarsService.Flags.BATTLE_TUTORIAL_COMPLETED):
		return 2
	elif not VarsService.get_flag(VarsService.Flags.SAVE_TUTORIAL_COMPLETED):
		return 3
	else:
		return DialogNodes.QUEST_DONE
			
		
