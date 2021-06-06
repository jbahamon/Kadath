extends HSplitContainer

onready var party_list = $PartyList


func initialize(party: Party):
	party_list.initialize(party)
	

func receive_focus():
	var first_element = $PartyList.get_first_item()

	if first_element != null:
		first_element.grab_focus()
		first_element.grab_click_focus()
		return true
	else:
		return false

func relinquish_focus():
	return
