class_name PriorityQueue

class PriorityQueueElement:
	var value
	var priority: int
	var counter
		
	func _init(init_value, init_priority: int, init_counter: int):
		value = init_value
		priority = init_priority
		counter = init_counter
		
	func gt(other_element: PriorityQueueElement):
		if priority != other_element.priority:
			return priority > other_element.priority
		else:
			return counter > other_element.counter
			
var counter = 0	
var _elements: Array = []

func is_empty() -> bool:
	return self._elements.size() == 0

func add(value, priority: int):
	var element = PriorityQueueElement.new(value, priority, counter)
	counter += 1
	_elements.append(element)
	self._move_up(_elements.size() - 1)

func pop_min() -> Array:
	if _elements.size() == 0:
		return []
	_swap(0, _elements.size() - 1)
	
	var min_element: PriorityQueueElement = _elements.pop_back()
	_move_down(0)
	
	for element in _elements:
		element.priority -= min_element.priority
		
	return min_element.value

func _move_up(index: int) -> void:
	while (index > 0):
		var parent = (index - 1)/2
		
		if _elements[parent].gt(_elements[index]):
			_swap(index, parent)
			index = parent
		else:
			return
		
func _move_down(index: int) -> void:
	while true:
		var biggest_index = index
		var left_child = (2 * index) + 1
		   
		if (left_child < _elements.size() and 
			_elements[biggest_index].gt(_elements[left_child])):
			biggest_index = left_child
		   
		# Right Child
		var right_child = (2 * index) + 2
		   
		if (right_child < _elements.size() and 
			_elements[biggest_index].gt(_elements[right_child])) :
			biggest_index = right_child
		   
		# If i not same as maxIndex
		if (index != biggest_index):
			_swap(index, biggest_index)
			index = biggest_index
		else:
			return

func _swap(i, j):
	var tmp = _elements[i]
	_elements[i] = _elements[j]
	_elements[j] = tmp
