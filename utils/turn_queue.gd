class_name TurnQueue

const CHARGE_TO_ACT = 100

class TurnQueueElement:
	var actor
	var remaining_charge: int
		
	func _init(init_actor):
		actor = init_actor
		remaining_charge = CHARGE_TO_ACT

	func get_time_to_act() -> int:
		return int(ceil(self.remaining_charge/self.actor.battler.speed))

	static func sort(a: TurnQueueElement, b: TurnQueueElement) -> bool:
		var time_diff = a.get_time_to_act() - b.get_time_to_act()
		
		if time_diff == 0:
			return a.get_instance_id() < b.get_instance_id()
		else:
			return time_diff < 0

var _elements: Array[TurnQueueElement] = []

func reset() -> void:
	self._elements = []

func is_empty() -> bool:
	return self._elements.size() == 0

func add(actor):
	var element = TurnQueueElement.new(actor)
	_elements.append(element)
	
func erase(actor):
	# note that we get the actor to erase, not the turn queue element. so we just search for it
	var index_to_remove = -1
	for i in range(self._elements.size()):
		if self._elements[i].actor == actor:
			index_to_remove = i
			break
	if index_to_remove >= 0:
		self._elements.remove_at(index_to_remove)
	
func get_preview(preview_size: int) -> Array:
	var ret = []
	
	var old_charges = {}
	
	for element in self._elements:
		old_charges[element] = element.remaining_charge

	for i in range(preview_size):
		var next_element = self.get_next_element()
		
		ret.append(next_element.actor)
		var time = next_element.get_time_to_act()
		
		for element in self._elements:
			element.remaining_charge = clamp(element.remaining_charge - time * element.actor.battler.speed, 0, 100)
		next_element.remaining_charge = CHARGE_TO_ACT
	
	for element in self._elements:
		element.remaining_charge = old_charges[element]
		
	return ret

func get_current_actor():
	assert(self._has_two_teams())
	
	var next_element = self.get_next_element()
	var time = next_element.get_time_to_act()
	
	for element in self._elements:
		element.remaining_charge = clamp(element.remaining_charge - time * element.actor.battler.speed, 0, 100)
	next_element.remaining_charge = CHARGE_TO_ACT
	
	next_element = self.get_next_element()
	
	return next_element.actor

func _has_two_teams() -> bool:
	var has_party_member = false
	var has_enemy = false
	
	for elem in self._elements:
		if elem.actor is PartyMember:
			has_party_member = true
		else:
			has_enemy = true
			
		if has_enemy and has_party_member:
			return true
	
	return false

func get_next_element() -> TurnQueueElement:
	assert(self._elements.size() > 0)
	
	var chosen_element: TurnQueueElement
	var max_time = INF
	
	for element in self._elements:
		var time = element.get_time_to_act()
		if time < max_time:
			chosen_element = element
			max_time = time
	
	return chosen_element
