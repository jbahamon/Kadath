class_name TurnQueue

const CHARGE_TO_ACT = 100

class TurnQueueElement:
	var battler: Battler
	var remaining_charge: int
		
	func _init(init_battler: Battler):
		battler = init_battler
		remaining_charge = CHARGE_TO_ACT

	func get_time_to_act() -> int:
		return int(ceil(self.remaining_charge/self.battler.get_speed()))

	static func sort(a: TurnQueueElement, b: TurnQueueElement) -> bool:
		var time_diff = a.get_time_to_act() - b.get_time_to_act()
		
		if time_diff == 0:
			return a.get_instance_id() < b.get_instance_id()
		else:
			return time_diff < 0

var _elements: Array = []

func reset() -> void:
	self._elements = []

func is_empty() -> bool:
	return self._elements.size() == 0

func add(battler: Battler):
	var element = TurnQueueElement.new(battler)
	_elements.append(element)
	
func erase(battler: Battler):
	var idx = 0
	for element in self._elements:
		if element.battler == battler:
			break
		else:
			idx += 1
	
	if idx < self._elements.size():
		self._elements.remove(idx)
	
func get_preview(preview_size: int) -> Array:
	var ret = []

	self._elements.sort_custom(TurnQueueElement, "sort")

	for i in range(preview_size):
		
		ret.append(self._elements[0].battler)
		var time = self._elements[0].get_time_to_act()
		
		for element in self._elements:
			element.remaining_charge = clamp(element.remaining_charge - time * element.battler.get_speed(), 0, 100)
		self._elements[0].remaining_charge = CHARGE_TO_ACT
		self._elements.sort_custom(TurnQueueElement, "sort")
	
	return ret

func get_current_battlers() -> Array:
	assert(self._has_two_teams())
	
	var ret = []
	
	self._elements.sort_custom(TurnQueueElement, "sort")

	var is_player_turn = self._elements[0].battler.is_party_member
	
	while self._elements[0].battler.is_party_member == is_player_turn:
		
		ret.append(self._elements[0].battler)
		var time = self._elements[0].get_time_to_act()
		
		for element in self._elements:
			element.remaining_charge = clamp(element.remaining_charge - time * element.battler.get_speed(), 0, 100)
		self._elements[0].remaining_charge = CHARGE_TO_ACT
		self._elements.sort_custom(TurnQueueElement, "sort")
	
	return ret

	
func _has_two_teams() -> bool:
	var has_party_member = false
	var has_enemy = false
	
	for elem in self._elements:
		if elem.battler.is_party_member:
			has_party_member = true
		else:
			has_enemy = true
			
		if has_enemy and has_party_member:
			return true
	
	return false
