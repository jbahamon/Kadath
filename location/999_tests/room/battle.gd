extends LocationRoom

@export var hp: Dictionary[String, int]
@export var ep: Dictionary[String, int]


func on_enter():
	
	for hp_name in hp:
		var party_member_idx = EntitiesService.party.active_members.find_custom(func (p): return p.name == hp_name)
		if party_member_idx >= 0:
			EntitiesService.party.active_members[party_member_idx].battler.health = hp[hp_name]
		else:
			get_node(NodePath(hp_name)).battler.health = hp[hp_name]

	for ep_name in ep:
		var party_member_idx = EntitiesService.party.active_members.find_custom(func (p): return p.name == ep_name)
		if party_member_idx >= 0:
			EntitiesService.party.active_members[party_member_idx].battler.energy = ep[ep_name]
		else:
			get_node(NodePath(ep_name)).battler.health = ep[ep_name]
