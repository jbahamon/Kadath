extends Reference
class_name Inventory

signal inventory_changed(change_type)

enum Change {
	ADD,
	REMOVE,
	SORT,
	SWAP
}

const save_key = 'inventory'
var amounts = {}
var order = []

export (int) var MAX_COINS = 9999999


func load(save_data: SaveData) -> void:
	self.amounts = save_data.data[save_key]['amounts']
	self.order = save_data.data[save_key]['order']

func save(save_data: SaveData) -> void:
	save_data.data[save_key] = {
		'amounts': self.amounts,
		'order': self.order
	}

func add(item: InventoryItem, amount: int = 1) -> void:
	if item in amounts:
		amounts[item] = min(amounts[item] + amount, item.max_amount)
	else:
		amounts[item] = min(amount, item.max_amount)
		order.push_back(item)
	
	emit_signal("inventory_changed", Change.ADD)
		
	
func remove(item: InventoryItem, amount: int = 1) -> void:
	assert(item in amounts)
	assert(amount <= amounts[item])
	assert(item in order)
	
	amounts[item] -= amount
		
	if amounts[item] <= 0:
		amounts.erase(item)
		order.erase(item)

	emit_signal("inventory_changed", Change.REMOVE)
	
func swap_items(i1: int, i2: int) -> void:
	var temp_item: InventoryItem = order[i1]
	order[i1] = order[i2]
	order[i2] = temp_item
	emit_signal("inventory_changed", Change.SWAP)

func has(item: InventoryItem):
	return item in amounts

func get_sorted_items_amounts() -> Array:
	var ids_and_amounts = []
	
	for item in order:
		ids_and_amounts.push_back([item, amounts[item]])
		
	return ids_and_amounts

func get_equipment(cls, equippable_flag: int) -> Array:
	var ret = []
	for item in order:
		if item is cls and (item.equippable_by & equippable_flag):
			ret.append(item)
	return ret

func sort():
	order.sort_custom(ItemSorter, "sort_ascending")
	emit_signal("inventory_changed", Change.SORT)
	
class ItemSorter:
	static func sort_ascending(a: InventoryItem, b: InventoryItem):
		if a.category != b.category:
			return a.get_class() < b.get_class()
		else:
			return a.name < b.name
