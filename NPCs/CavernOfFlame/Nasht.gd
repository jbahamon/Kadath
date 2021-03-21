extends BaseNPC

enum DialogNodes {
	BEFORE_QUEST = 1,
	IN_QUEST = 4,
	QUEST_DONE = 5,
	AFTER_AMULET_RECEIVED = 7,
}

func _ready():
	if Inventory.has("amulet"):
		dialog_nid = DialogNodes.AFTER_AMULET_RECEIVED
	else:
		dialog_nid = DialogNodes.BEFORE_QUEST
	
func on_player_interaction(player: Player):
	if dialog_nid == DialogNodes.IN_QUEST and false: # Check condition
		dialog_nid = DialogNodes.QUEST_DONE
	
	.on_player_interaction(player)
	
	match dialog_nid:
		DialogNodes.BEFORE_QUEST:
			dialog_nid = DialogNodes.IN_QUEST
		DialogNodes.QUEST_DONE:
			if not Inventory.has("amulet"):
				Inventory.add_item("amulet")
			dialog_nid = DialogNodes.AFTER_AMULET_RECEIVED
