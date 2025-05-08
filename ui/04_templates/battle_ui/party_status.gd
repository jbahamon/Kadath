extends BoxContainer


# Called when the node enters the scene tree for the first time.
func initialize(party_members: Array):
	var i = 0
	for party_member_item in self.get_children():
		if i < party_members.size():
			party_member_item.party_member = party_members[i]
		else:
			party_member_item.party_member = null
		
		i += 1
		party_member_item.update()

func update():
	for control in self.get_children():
		control.update()
